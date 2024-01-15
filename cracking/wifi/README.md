# WiFi WPA2 handshake cracking


## Extracting access point MAC addresses, for which handshake was captured from wireshark / airodump-ng .cap / .pcap file

Sometimes you are getting quite big dump of traffic to .cap file with airodump-ng (or similar tools). It's quite hard to check it manually
and extract MAC addresses of access points (BSSID) for which WPA2 4-way handshake (EAPOL) was captured.

Instead of doing it manually with Wireshark, you can do it in terminal with

```bash
tshark -r file.cap -Y eapol -T fields -e wlan.bssid | sort -u
```

Note, that if handshake is not complete, it might not be enough for handshake cracking attempt. See - https://aircrack-ng.org/doku.php?id=wpa_capture 
