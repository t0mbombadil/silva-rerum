## SSH USEFUL STUFF

src -  https://bash-prompt.net/guides/ssh-keep-socket/
Add to ~/.ssh/config following lines to persist connections for 10 minutes
```bash
Host *
  ControlPath    ~/.ssh/%C.sock
  ControlMaster  auto
  ControlPersist 10m
```
