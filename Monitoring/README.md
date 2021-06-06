## Linux - getting last activity on system

With commands below you could see last activies on the system - logged users / if they are still logged in / reboots / commands running and sudo usage.

```bash
#> last | less
```
```bash
#> lastlog
```

```bash
#> sudo zgrep -e '(login|attempt|auth|success):' /var/log/*
```
src - https://serverfault.com/questions/144656/how-to-see-activity-logs-on-a-linux-pc
