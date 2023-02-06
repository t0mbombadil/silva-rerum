## Container tricks

Run shell in docker container with all tools required for debugging
```bash
docker exec -it -u root <container_name> bash -c "apt update -y && apt install net-tools procps lsof vim -y && bash"
```
