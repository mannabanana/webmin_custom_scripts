#!/bin/bash

PC=${NAME::${#NAME}-3}
if [ $PC = dt ] || [ $PC = ws ] || [ $PC = xz ] || [ $PC = pc ]
then
NUM=${NAME:2}
if [ $NUM -gt 100 ] && [ $NUM -lt 256 ]
then
#attempts to find user's pc name
if egrep '*\<'$NAME'\>.*' /etc/squid/squid.conf > /dev/null;
then
sed -i '/'$NAME'/s/#acl/acl/g' /etc/squid/squid.conf
sed -i '/'$NAME'/s/#http_access/http_access/g' /etc/squid/squid.conf
#looking for a point '.' at the begin of address. if it's absent the script would add '.'
if [ ${URL:0:1} != . ]
then
URL='.'$URL
fi

#attempts to check a blocking address. The full domain name is not a good idea
TLD3=${URL:${#URL}-4}
TLD2=${URL:${#URL}-3}
if [ $TLD3 = .com ] || [ $TLD3 = .net ] || [ $TLD3 = .org ] || [ $TLD3 = .gov ] && [ ${#URL} -eq ${#TLD3} ]
then
echo "Incorrect '$URL'"
exit 0
elif [ $TLD2 = .ru ] && [ ${#URL} -eq ${#TLD2} ]
then
echo "Incorrect '$URL'"
exit 0
fi

#find the user's PC file
if [ -f /etc/squid/block_pc/block_$PC/$NAME.txt ]
then
#looking for the address in the file
if egrep '^#'$URL'$' /etc/squid/block_pc/block_$PC/$NAME.txt
then
sed -i 's/#'$URL'/'$URL'/g' /etc/squid/block_pc/block_$PC/$NAME.txt
cat /etc/squid/block_pc/block_$PC/$NAME.txt
/bin/systemctl restart squid.service
#if the address have been blocked yet
elif egrep '^'$URL'$' /etc/squid/block_pc/block_$PC/$NAME.txt
then
echo "'$URL' exist"
cat /etc/squid/block_pc/block_$PC/$NAME.txt
else
#if the address haven't been blocked
echo -e "$URL" >> /etc/squid/block_pc/block_$PC/$NAME.txt
cat /etc/squid/block_pc/block_$PC/$NAME.txt
/bin/systemctl restart squid.service
fi
#if the file of blocking doesn't found
else
touch /etc/squid/block_pc/block_$PC/$NAME.txt
echo -e "$URL" >> /etc/squid/block_pc/block_$PC/$NAME.txt
/bin/systemctl restart squid.service
fi
#else
#echo "Incorrect '$URL'"
#fi
else
echo "'$NAME' doesn't exist"
fi
else
echo "Incorrect number"
fi
else
echo "Incorrect computer name"
fi