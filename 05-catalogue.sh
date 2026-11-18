app_name=catalogue
source ./common.sh
check_root

app_setup
nodejs_setup
systemd_setup


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "adding mongo repo"

dnf install mongodb-mongosh -y  &>> $LOGS_FILE
VALIDATE $? "installing mongosh client"

INDEX=$(mongosh --host mongodb.venkatcloudstack.shop --eval "db.getSiblingDB('catalogue').getCollectionNames().includes('products')")

if [ $INDEX = "false" ]; then
    mongosh --host mongodb.venkatcloudstack.shop </app/db/master-data.js
    VALIDATE $? "loading products to mongodb"
else
    echo -e "products already loaded .. $Y SKIPPING $N "
fi
app_restart

 
print_total_time

