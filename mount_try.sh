#!/bin/bash
SHARES="Data data Public public Share share AI Models DietPi dietpi BabciaTobiasz Users 'Macintosh HD'"
mkdir -p /mnt/nas
for share in $SHARES; do
  echo "Trying $share..."
  mount -t cifs "//192.168.1.188/$share" /mnt/nas -o guest,vers=3.0,sec=ntlmssp && echo "SUCCESS GUEST: $share" && exit 0
  mount -t cifs "//192.168.1.188/$share" /mnt/nas -o user=dietpi,password='Adelakun34.12!',vers=3.0,sec=ntlmssp && echo "SUCCESS DIETPI: $share" && exit 0
done
echo "ALL FAILED"
