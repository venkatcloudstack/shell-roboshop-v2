
source ./common.sh


check_root

dnf module disable redis -y &>> $LOGS_FILE
VALIDATE $? "disable default redis"
dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "enable redis new version"

dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g'  -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "allowing remote connections"


systemctl enable redis 
systemctl start redis 
VALIDATE $? "started redis"

print_total_time