# Check IP reputation

```bash
# This way you can also pipe more IPs & save output to file
echo "1.1.1.1" | xargs -I "{}" curl "https://talosintelligence.com/cloud_intel/ip_reputation?ip={}" -A "ReqBin/1.0" | jq .reputation
```
