# Podman setup on m1 mac

```
brew install podman
podman machine init
podman machine start

# Qemu required for x86/x64 emulation
podman machine ssh sudo rpm-ostree install qemu-user-static

# Run x86/x64 image
podman run --net none  --platform=amd64 -it dxa4481/trufflehog

```
