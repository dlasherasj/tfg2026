#!/bin/sh

# pwsh -Command ./vm_crea_pcv.ps1 PCV-dlj1

for i in `cat pcvs.txt`
do

 echo "Creando $i..."

 pwsh -Command ./vm_crea_pcv.ps1 $i

 printf "$i|" >> mac_pcvs.txt
 pwsh -Command ./vm_get_mac.ps1 $i | tail -2 |head -1 >> mac_pcvs.txt

 #export SSHPASS='P6nun:ec' ; sshpass -e ssh adminboe@deploy "DSADD COMPUTER cn=$i,ou=VDI,ou=PCsW10,ou=Equipos,dc=boe,dc=int"
 export SSHPASS='xxxx' ; sshpass -e ssh admin@deploy "DSADD COMPUTER cn=$i,ou=VDI,ou=PCsW10,ou=Equipos,dc=boe,dc=int"
done
