# Check IP reputation 

## API response in terminal
```bash
# This way you can also pipe more IPs & save output to file
# tac might be required so stdin is no closed incorrectly (which would generate curl error)

echo "1.1.1.1" | xargs -I "{}" sh -c 'echo "IP: {}" ; curl "https://talosintelligence.com/cloud_intel/ip_reputation?ip={}" -A "ReqBin/1.0" | tac | tac | jq .reputation'
```

## Open in browser
You can also open Talos & virus total urls in browser for more readable output
```bash
# For MacOS
echo "1.1.1.1" | xargs -I {} open 'https://talosintelligence.com/reputation_center/lookup?search={}' ; open 'https://www.virustotal.com/gui/ip-address/{}'
```
