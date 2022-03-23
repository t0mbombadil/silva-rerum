# Check IP reputation

```bash
# This way you can also pipe more IPs & save output to file
# tac might be required so stdin is no closed incorrectly (which would generate curl error)

echo "1.1.1.1" | xargs -I "{}" sh -c 'echo "IP: {}" ; curl "https://talosintelligence.com/cloud_intel/ip_reputation?ip={}" -A "ReqBin/1.0" | tac | tac | jq .reputation'
```
