#!/bin/bash

if [ "$NAME" = "root" ]
then echo "Don't touch root"
exit 0
fi

#если есть скрипт на отключение, то автоответ уже включен
if [ -f /etc/webmin/scripts/autoreplyout_$NAME.bash ]
then
echo "Autoreply exist"
exit 0
fi

DATE=`date +%Y-%-m-%-d`
if [ $DATE_ON != "-1-" ] && [ "$DATE" \> "$DATE_ON" ]
then
echo "Starting date of autoreply is wrong"
exit 0
fi

if [ $DATE_OFF = "-1-" ]
then
echo "Ending date of autoreply doesn't set"
exit 0
fi

DATE_END="2038-1-18"

if [ "$DATE" \> "$DATE_OFF" ] || [ "$DATE_OFF" \> "$DATE_END" ]
then
echo "Ending date of autoreply is wrong"
exit 0
fi

#если такой пользователь существует, то создается сообщение с автоответом; скрипт, который
#запускает автоответ (либо по указанной дате, либо сразу же автоматически); скрипт, который
#отключает автоответ по дате
if [ -f /var/spool/mail/$NAME ]
then
touch /etc/postfix/autoreply_msg/$NAME.msg
echo -e $TEXT > /etc/postfix/autoreply_msg/$NAME.msg
FILE_IN=/etc/webmin/scripts/autoreply_$NAME.bash
touch $FILE_IN
chown root:root $FILE_IN
chmod +x $FILE_IN
cp /etc/webmin/scripts/autoreply.bash $FILE_IN
sed -i 's/login/'$NAME'/g' $FILE_IN
if [ $DATE_ON = "-1-" ]
then
at -f $FILE_IN -v now
else
at -f $FILE_IN -v midnight $DATE_ON
fi
if [ ! -f /etc/postfix/scripts/autoreply_$NAME.pl ]
then
FILE=/etc/postfix/scripts/autoreply_$NAME.pl
touch $FILE
chown autoreply:autoreply $FILE
chmod +x $FILE
cp /etc/postfix/scripts/autoreply.pl $FILE
sed -i 's/noreply/'$NAME'/g' $FILE
fi
/bin/systemctl restart postfix.service

FILE_OUT=/etc/webmin/scripts/autoreplyout_$NAME.bash
touch $FILE_OUT
chown root:root $FILE_OUT
chmod +x $FILE_OUT
cp /etc/webmin/scripts/unautoreply.bash $FILE_OUT
sed -i 's/login/'$NAME'/g' $FILE_OUT
at -f $FILE_OUT -v midnight $DATE_OFF
if [ $DATE_ON = "-1-" ]
then
echo "!Success! Autoreply is working from $DATE to $DATE_OFF"
else
echo "!Success! Autoreply is working from $DATE_ON to $DATE_OFF"
fi
else
echo "User doesn't exist"
exit 0
fi