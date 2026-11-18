
source ./common.sh

check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOGS_FILE
VALIDATE $? "adding rabbitmq repo"

dnf install rabbitmq-server -y  &>> $LOGS_FILE
VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOGS_FILE
systemctl start rabbitmq-server  &>> $LOGS_FILE
VALIDATE $? "enabling starting rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "user and password setup"

print_total_time