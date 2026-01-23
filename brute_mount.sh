#!/bin/bash
SHARES="Data Public Guest Shared"
USERS="Guest guest DietPi dietpi"
VERSIONS="3.0 2.0"
SECS="ntlmssp ntlmv2"

mkdir -p /mnt/nas

for share in $SHARES; do
  for user in $USERS; do
    for vers in $VERSIONS; do
      for sec in $SECS; do
        if [[ "$user" == "Guest" || "$user" == "guest" ]]; then
           PASS=""
        else
           PASS="Adelakun34.12!"
        fi
        
        echo "Trying Share=$share User=$user Vers=$vers Sec=$sec..."
        mount -t cifs "//192.168.1.188/$share" /mnt/nas -o "user=$user,password=$PASS,vers=$vers,sec=$sec" 2>/dev/null 
        
        if [ $? -eq 0 ]; then
             echo "SUCCESS: Share=$share User=$user Vers=$vers Sec=$sec"
             exit 0
        fi
      done
    done
  done
done
echo "ALL BRUTE ATTEMPTS FAILED"
