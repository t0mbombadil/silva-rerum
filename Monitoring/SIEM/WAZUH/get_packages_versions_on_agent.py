#!/usr/bin/env python3
"""
Query package versions across all Wazuh agents.

Example usage
-------------
# Credentials only have to be exported once
export WAZUH_USER="alice"
read -s WAZUH_PASS && export WAZUH_PASS="$WAZUH_PASS"

# Optional: override the Wazuh proxy host
# export WAZUH_HOST="wazuh.example.com"

# Run the script
./get_packages_versions_on_agent.py -p ssh
"""
import argparse
import asyncio
import base64
import os
from argparse import RawTextHelpFormatter
from typing import Dict, Set

import aiohttp


# ------------------------ CLI parsing ------------------------ #
def arg_parse():
    """Return parsed command-line arguments."""
    script = os.path.basename(__file__)
    default_host = os.environ.get("WAZUH_HOST", "wazuh.example.com")

    parser = argparse.ArgumentParser(
        description=f"Get package version across all Wazuh agents.\n\n"
        f"Example:\n  ./{script} -p ssh",
        formatter_class=RawTextHelpFormatter,
    )

    parser.add_argument(
        "-p",
        "--package",
        required=True,
        help="Substring to match against package names (e.g. 'ssh')",
    )

    parser.add_argument(
        "-u",
        "--user",
        default=f"{os.environ.get('WAZUH_USER')}:{os.environ.get('WAZUH_PASS')}",
        help="Credentials in the form username:password "
        "(defaults to $WAZUH_USER:$WAZUH_PASS)",
    )

    parser.add_argument(
        "--host",
        default=default_host,
        help=f"Wazuh proxy host (default: {default_host}) "
        "(can also be set via $WAZUH_HOST)",
    )

    args = parser.parse_args()

    if not args.user or ":" not in args.user:
        parser.error("Credentials must be supplied as username:password")

    return args


# ------------------------ Data classes ----------------------- #
class WazuhAgent:
    def __init__(self, agent_id: str, name: str, ip: str, os_string: str):
        self.id = agent_id
        self.name = name
        self.ip = ip
        self.os = os_string
        self.packages: Dict[str, str] = {}

    def __hash__(self) -> int:
        return hash(self.id)

    def __str__(self) -> str:
        header = f"[{self.name}][{self.ip}][{self.os}]"
        if not self.packages:
            return f"{header} - No matching packages"
        pkg_lines = "\n".join(f"{k} {v}" for k, v in self.packages.items())
        return f"{header}\n--packages--\n{pkg_lines}\n"

    __repr__ = __str__  # identical output


# ------------------------ API client ------------------------- #
class WazuhApiClient:
    """Minimal async client for Wazuh DevTools API."""

    def __init__(self, username: str, password: str, host: str):
        self.auth_header = self._build_auth_header(username, password)
        self.host = host.rstrip("/")  # tidy input

    @staticmethod
    def _build_auth_header(username: str, password: str) -> str:
        creds = f"{username}:{password}".encode()
        return "Basic " + base64.b64encode(creds).decode()

    async def _api_request(self, session: aiohttp.ClientSession, json_body: dict):
        """POST a DevTools request to /api/request and return JSON."""
        request_id = "1514629884013"  # random id, required by wazuh. Can be reused between requests
        headers = {
            "accept": "application/json",
            "content-type": "application/json",
            "id": request_id,
            "kbn-xsrf": "kibana",
            "authorization": self.auth_header,
        }
        json_body["id"] = request_id
        url = f"https://{self.host}/api/request"

        async with session.post(url, json=json_body, headers=headers) as resp:
            resp.raise_for_status()
            return await resp.json()

    # ---------- Public high-level helpers ---------- #
    async def fetch_agents(self) -> Set[WazuhAgent]:
        """Return a set of active agents."""
        body = {
            "method": "GET",
            "path": "/agents",
            "body": {"status": "Active", "devTools": True},
        }
        async with aiohttp.ClientSession() as session:
            data = await self._api_request(session, body)

        agents: Set[WazuhAgent] = set()
        for item in data["data"]["items"]:
            os_string = (
                f"{item['os']['name']} {item['os']['version']} {item['os']['codename']}"
            )
            agents.add(
                WazuhAgent(
                    agent_id=item["id"],
                    name=item["name"],
                    ip=item["ip"],
                    os_string=os_string,
                )
            )
        return agents

    async def _fetch_packages(
        self, session: aiohttp.ClientSession, agent_id: str, package: str
    ) -> Dict[str, str]:
        body = {
            "method": "GET",
            "path": f"/syscollector/{agent_id}/packages",
            "body": {"search": package, "devTools": True},
        }
        result = await self._api_request(session, body)
        return {pkg["name"]: pkg["version"] for pkg in result["data"]["items"]}

    async def fetch_packages_for_agents(
        self, package: str
    ) -> Set[WazuhAgent]:
        """Return agents populated with package versions."""
        agents = await self.fetch_agents()

        async with aiohttp.ClientSession() as session:
            # launch all requests in parallel
            tasks = {
                agent: asyncio.create_task(
                    self._fetch_packages(session, agent.id, package)
                )
                for agent in agents
            }
            await asyncio.gather(*tasks.values())

        # attach results
        for agent, task in tasks.items():
            agent.packages = task.result()

        return agents


# ---------------------------- Main --------------------------- #
if __name__ == "__main__":
    args = arg_parse()

    user, pwd = args.user.split(":", 1)
    client = WazuhApiClient(user, pwd, host=args.host)

    print(f"Querying package '{args.package}' on {args.host} ...")
    agents = asyncio.run(client.fetch_packages_for_agents(package=args.package))

    print("\nResults:\n")
    for agent in sorted(agents, key=lambda a: a.name.lower()):
        print(agent)
