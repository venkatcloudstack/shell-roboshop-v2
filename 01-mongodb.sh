
source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "adding mongo repo"

dnf install mongodb-org -y  &>> $LOGS_FILE
VALIDATE $? "installing mongodb server"

systemctl enable --now mongod &>> $LOGS_FILE
VALIDATE $? "enable and start mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connection to mongodb"


systemctl restart mongod
VALIDATE $? "restarting mongodb"

print_total_time
