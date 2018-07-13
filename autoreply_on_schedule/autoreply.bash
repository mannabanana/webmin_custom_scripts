#!/bin/bash

if grep -e '\<autoreply_login\>' /etc/postfix/master.cf > /dev/null
then
sed -i '/autoreply_login/s/#autoreply_login unix/autoreply_login unix/g' /etc/postfix/master.cf
sed -i '/autoreply_login.pl/s/#flags=R/flags=R/g' /etc/postfix/master.cf
else
echo -e "autoreply_login unix    -       n       n       -       -       pipe" >> /etc/postfix/master.cf
echo -e "	flags=R user=autoreply   argv=/etc/postfix/scripts/autoreply_login.pl $"{sender}" $"{recipient}"" >> /etc/postfix/master.cf
fi
if grep -e '\<login\>' /etc/postfix/transport > /dev/null
then
sed -i '/login/s/#login.autoreply.mailtest.avionics/login.autoreply.mailtest.avionics/g' /etc/postfix/transport
else
echo -e "login.autoreply.mailtest.avionics	autoreply_login:" >> /etc/postfix/transport
fi
postmap /etc/postfix/transport
if grep -e '\<login\>' /etc/postfix/virtual > /dev/null
then
sed -i '/login/s/#login@mailtest.avionics/login@mailtest.avionics/g' /etc/postfix/virtual
else
echo -e "login@mailtest.avionics login@mailtest.avionics	login@login.autoreply.mailtest.avionics" >> /etc/postfix/virtual
fi
postmap /etc/postfix/virtual
rm -f /etc/webmin/scripts/autoreply_login.bash