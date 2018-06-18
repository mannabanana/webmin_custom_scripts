#!/bin/bash

#проверяет есть ли точка перед ссылкой, если нет, то добавляет
URL=${URL,,}
if [ ${URL:0:1} != . ]
then
URL='.'$URL
fi

#attempts to check a blocking address. The full domain name is not a good idea
TLD=${URL##*.}
if grep -e '^'$TLD'\>' /etc/webmin/scripts/dns_name.txt > /dev/null
then
if [ ${#URL} -eq ${#TLD} ]
then
echo "To block all domain is not good"
exit 0
fi
else
echo "Incorrect '$URL'"
exit 0
fi

NAME=${NAME,,}
PC=${NAME::${#NAME}-3}
if [ $PC = dt ] || [ $PC = ws ] || [ $PC = zx ] || [ $PC = pc ]
then
NUM=${NAME:2}
if [ $NUM -gt 100 ] && [ $NUM -lt 256 ]
then
if egrep '*\<'$NAME'\>.*' /etc/squid/squid.conf > /dev/null;
then
sed -i '/'$NAME'/s/#acl/acl/g' /etc/squid/squid.conf
sed -i '/'$NAME'/s/#http_access/http_access/g' /etc/squid/squid.conf

#find the user's PC file
if [ -f /etc/squid/block_pc/block_$PC/$NAME.txt ]
then
#looking for the address in the file
if egrep '^#'$URL'$' /etc/squid/block_pc/block_$PC/$NAME.txt
then
sed -i 's/#'$URL'/'$URL'/g' /etc/squid/block_pc/block_$PC/$NAME.txt
echo "All list of blocking sites"
cat /etc/squid/block_pc/block_$PC/$NAME.txt
/bin/systemctl restart squid.service
#if the address haven't been blocked
elif egrep '^'$URL'$' /etc/squid/block_pc/block_$PC/$NAME.txt
then
echo "'$URL' exist"
echo "All list of blocking sites"
cat /etc/squid/block_pc/block_$PC/$NAME.txt
else
#if the file of blocking doesn't found
echo -e "$URL" >> /etc/squid/block_pc/block_$PC/$NAME.txt
cat /etc/squid/block_pc/block_$PC/$NAME.txt
/bin/systemctl restart squid.service
fi
else
touch /etc/squid/block_pc/block_$PC/$NAME.txt
echo -e "$URL" >> /etc/squid/block_pc/block_$PC/$NAME.txt
/bin/systemctl restart squid.service
fi

else
echo "'$NAME' doesn't exist"
fi
else
echo "Incorrect number"
fi
else
echo "Incorrect computer name"
fi