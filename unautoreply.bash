#!/bin/bash

sed -i '/login/s/autoreply_login unix/#autoreply_login unix/g' /etc/postfix/master.cf
sed -i '/login/s/flags=R/#flags=R/g' /etc/postfix/master.cf
sed -i '/login/s/login.autoreply.2100.gosniias.ru/#login.autoreply.2100.gosniias.ru/g' /etc/postfix/transport
postmap /etc/postfix/transport
sed -i '/login/s/login@2100.gosniias.ru/#login@2100.gosniias.ru/g' /etc/postfix/virtual
postmap /etc/postfix/virtual
/bin/systemctl restart postfix.service
rm -f /etc/webmin/scripts/autoreplyout_login.bash