# Podman setup on m1 mac

```
brew install podman
podman machine init
podman machine start

# Qemu required for x86 emulation
podman machine ssh sudo rpm-ostree install qemu-user-static

```
