#!/bin/bash
DATE=$(date +%F)
SCRIPT_NAME=$0
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log
IDUSER=$(id -u)
Mongodb_Host=mongodb.manacars.shop
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"



VALIDATE(){
    if [ $1 -ne 0 ];
    then 
        echo -e "$2....$R FAILURE $N"
        exit 1
    else 
        echo -e "$2....$G SUCCESS $N"
    fi 
}

if [ $IDUSER -ne 0 ];
then 
    echo -e " $R ERROR: Your are not the root user $N"
    exit 1
else 
    echo -e " $G Your are the root user $N"
fi 

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disable nodejs "

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enable Nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? " Install nodejs"

id=roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop 
    echo -e " $G Roboshop user creation $N"
else 
    echo -e " Roboshop user already exists $Y SKIPPING $N"
fi

mkdir -p /app 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading catalogue"

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzip the files"

cd /app 

npm install &>> $LOGFILE

VALIDATE $? "Install npm"

cp /home/centos/manacars/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "Copying files"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? " Daemon reload"

systemctl enable catalogue  &>> $LOGFILE

VALIDATE $? "Enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "start catalogue"

cp /home/centos/manacars/mongodb.repo /etc/yum.repos.d/mongo.repo 

VALIDATE $? "Copying the files mongodb"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Install mongodb"

mongo --host $Mongodb_Host </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? " Connecting mongodb"


