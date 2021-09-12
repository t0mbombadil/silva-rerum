### Strings generator for bruteforce
```bash
charList="0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,a,b,c,d,e,f";keyGen="";for j in {1..3}; do keyGen="$keyGen$(echo "{$charList}")";done;eval echo  "$keyGen"
```
