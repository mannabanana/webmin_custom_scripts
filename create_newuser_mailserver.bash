#!/bin/bash
PASS=********

#Check result. Find folders of new user
if [ "$NAME" = "root" ]
then echo "Don't touch root"
    exit 0
fi
if [ -f /var/spool/mail/$NAME ];
then echo "User exist"
    exit 0
fi
if [ "$PASSWD1" != "$PASSWD2" ]
then echo "Password doesn't match"
    exit 0
fi
/usr/sbin/useradd -g users -s /dev/null $NAME
if [ -f /var/spool/mail/$NAME ];
then
echo "$PASSWD1" | /usr/bin/passwd $NAME --stdin
echo "New user $NAME create"
else echo "User $NAME doesn't exist"
    exit 0
fi
#Add new user to alllist1. Find line and add to end of line
if grep -e '^alllist1.*\<'$NAME'\>' /etc/aliases > /dev/null;
then echo "User $NAME already exist"
else sed -i '/alllist1/s/$/, '$NAME'/' /etc/aliases | echo "User $NAME was added to alllist1"
fi
/usr/bin/newaliases;
grep -n '\<'$NAME'\>' /etc/aliases;
#Add rights for user and check
chmod a+wr /var/mail/$NAME;
ls -l /var/mail/$NAME;
#Add AntiSpam
if [ -f /home/$NAME/.procmailrc ]
then
echo "File .procmailrc exist"
else
touch /home/$NAME/.procmailrc
echo "File .procmailrc was created"
fi
chown $NAME:users /home/$NAME/.procmailrc
echo ":0:" >> /home/$NAME/.procmailrc
echo "* ^X-KLMS-AntiSpam-Status: spam" >> /home/$NAME/.procmailrc
echo "mail/spam" >> /home/$NAME/.procmailrc
echo "Antispam was configured"
ls -la /home/$NAME/

sshpass -p ''$PASS'' ssh root@192.168.120.4 -o StrictHostKeyChecking=no ". /etc/webmin/scripts/itraffic.bash $NAME $IP"
