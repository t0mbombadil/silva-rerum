#!/bin/bash

# Gets multisport OTP, you need to provide for sport exercise you want to visit (so basically daily)
# With this script it's much faster than log in to website, then get code
#
# Works with Mac OS keychain

# Add password 
#security add-generic-password -a $(users) -s multisport -w $pass

# Get password
# security find-generic-password -a $(users) -s multisport -w

# To delete password run
# security delete-generic-password -a $(users) -s multisport 

user="mail@gmail.com"
passname='multisport'; 
if [[ -z $(security find-generic-password -a $(users) -s $passname -w) ]]; then 
  echo "Password: "; security add-generic-password -a $(users) -s $passname -w ; 
fi

# Log in
curl 'https://www.kartamultisport.pl/headless/login?no_cache=1&tx_felogin_login%5Baction%5D=login&tx_felogin_login%5Bcontroller%5D=Login' \
  -H 'Connection: keep-alive' \
  -H 'Accept: application/json, text/plain, */*' \
  -H 'DNT: 1' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Sec-GPC: 1' \
  -H 'Origin: https://www.kartamultisport.pl' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: https://www.kartamultisport.pl/login' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'Cookie: cookie_consent=allow' \
  --data-raw 'pid=44&logintype=login&redirect_url=&noredirect=false&redirectReferrer=&referer=&submit=Zaloguj&__referrer%5B%40extension%5D=Felogin&__referrer%5B%40controller%5D=Login&__referrer%5B%40action%5D=login&__referrer%5B%40request%5D=%7B%22%40extension%22%3A%22Felogin%22%2C%22%40controller%22%3A%22Login%22%2C%22%40action%22%3A%22login%22%7D4f9ec7fb71786854d099988fec43fb241b4f19d9&__trustedProperties=%7B%22user%22%3A1%2C%22pass%22%3A1%2C%22logintype%22%3A1%2C%22pid%22%3A1%7D44af962b81c101cb0713f576d5a079c36f139e8e' \
--data-urlencode "pass=$(security find-generic-password -a $(users) -s $passname -w)" \
--data-urlencode "user=$user" \
  --compressed --cookie-jar /tmp/mcookie.txt;
  
# Get code
curl 'https://www.kartamultisport.pl/headless/multisport/oferta-online/wspieraj-kluby?type=22320&tx_benefitbase_popup\[hash\]=77fd0e72e93a60759edfdc7bf8ea5b9ea78b7abc&tx_benefitbase_popup\[ttContent\]=823&tx_benefitbase_popup\[table\]=tt_content&tx_benefitbase_popup\[CType\]=benefit_banner&tx_benefitbase_popup\[page\]=46' \
  -H 'Connection: keep-alive' \
  -H 'Accept: application/json, text/plain, */*' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36' \
  -H 'DNT: 1' \
  -H 'Sec-GPC: 1' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: https://www.kartamultisport.pl/multisport/oferta-online/wspieraj-kluby' \
  -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' -b /tmp/mcookie.txt --compressed
