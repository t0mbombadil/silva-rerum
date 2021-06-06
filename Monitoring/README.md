## Linux - getting last activity on system

With commands below you could see last activies on the system - logged users / if they are still logged in / reboots / commands running and sudo usage.

```bash
last | less
```
```bash
lastlog
```

```bash
sudo zgrep -e '(login|attempt|auth|success):' /var/log/*
```
src - https://serverfault.com/questions/144656/how-to-see-activity-logs-on-a-linux-pc

To get all users shells history (.bash_history / .zsh_history / .python_history etc.) run:
```bash
sudo find / -name ".*_history" | sudo xargs tail -n 100 | less
```
Note: It might be easily tampered by users
