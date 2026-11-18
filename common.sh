#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR="$PWD"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d %H-%M-%S")
MYSQL_HOST=mysql.venkatcloudstack.shop

echo " $TIMESTAMP [INFO] script started "

check_root(){
    USERID=$(id -u)
    if [ $USERID -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $R please run this script with root access $N" | tee -a $LOGS_FILE
        exit 1
    fi
}

VALIDATE () {

    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 is ...$R FAILED $N " | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 is ...$G SUCCESS $N" | tee -a $LOGS_FILE
    fi    
}

print_total_time(){

    echo -e " $TIMESTAMP [INFO] script excuted in  $G $SECONDS seconds $N "
}

app_setup(){
    id roboshop         &>> $LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "creating systemuser"
    else 
        echo -e "user roboshop is already created ...$Y SKIPPING $N"
    fi

    rm -rf /app  
    VALIDATE $? "removing existing code"
    rm -rf /tmp/$app_name.zip  
    VALIDATE $? "removing $app_name zip"
    mkdir -p /app 
    VALIDATE $? "app directory created"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip   &>> $LOGS_FILE
    cd /app 
    unzip /tmp/$app_name.zip   &>> $LOGS_FILE
    VALIDATE $? "downloaded and extracted code"


}

nodejs_setup(){
    dnf module disable nodejs -y    &>> $LOGS_FILE
    VALIDATE $? "disabling nodejs"

    dnf module enable nodejs:20 -y  &>> $LOGS_FILE
    VALIDATE $? "enabling nodejs"

    dnf install nodejs -y           &>> $LOGS_FILE
    VALIDATE $? "installing nodejs"


    cd /app 
    npm install  &>> $LOGS_FILE
    VALIDATE $? "downloading dependecies"

}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
        VALIDATE $? "created systemctl service"

    systemctl daemon-reload  &>> $LOGS_FILE
    systemctl enable $app_name
    VALIDATE $? "enabling $app_name services"

}

app_restart(){
    systemctl daemon-reload     &>> $LOGS_FILE
    systemctl enable $app_name  &>> $LOGS_FILE
    systemctl restart $app_name &>> $LOGS_FILE
    VALIDATE $? "restarting $app_name"
}

java_setup (){
    dnf install maven -y  &>> $LOGS_FILE
    VALIDATE $? "installing maven"
    cd /app 
    mvn clean package   &>> $LOGS_FILE
    VALIDATE $? "downloading dependecies"
    mv target/shipping-1.0.jar shipping.jar 
    VALIDATE $? "adding shipping.jar file"

}