
source ./common.sh

check_root

dnf install mysql-server -y  &>> $LOGS_FILE
VALIDATE $? "installing mysql-server"

systemctl enable mysqld &>> $LOGS_FILE
systemctl start mysqld  &>> $LOGS_FILE
VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "set root password"
 
print_total_time