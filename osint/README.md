# Check IP reputation

```bash
# This way you can also pipe more IPs & save output to file
echo "1.1.1.1" | xargs -I "{}" curl "https://talosintelligence.com/cloud_intel/ip_reputation?ip={}" -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.74 Safari/537.36' | jq .reputation
```
