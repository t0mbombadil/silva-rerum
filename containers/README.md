## Container tricks

Run shell in docker container with all tools required for debugging. You don't want those install in runtime, since usually they are not needed
```bash
docker exec -it -u root <container_name> bash -c "apt update -y && apt install net-tools procps lsof vim less strace iproute2 -y && bash"
```
