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

VALIDATE $? " Disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? " Enable nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? " Installing nodejs"

id=roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop 
    echo -e " $G Roboshop user creation $N"
else 
    echo -e " Roboshop user already exists $Y SKIPPING $N"
fi

mkdir -p /app 

VALIDATE $? " Creating directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? " Downloading the user files"

cd /app 

unzip -O /tmp/user.zip &>> $LOGFILE 

VALIDATE $? " Unziping the files"

cd /app 

npm install &>> $LOGFILE

VALIDATE $? " Insralling npm"

cp /home/centos/manacars/user.service /etc/systemd/system/user.service

VALIDATE $? "copying the files"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? " Daemon reload user"

systemctl enable user  &>> $LOGFILE

VALIDATE $? " Enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Start user"

cp /home/centos/manacars/mongodb.repo/ /etc/yum.repos.d/mongo.repo

VALIDATE $? " Copying mongodb files"

dnf install mongodb-org-shell -y &>> $LOGFILE 

VALIDATE $? " Installing mongodb"

mongo --host $Mongodb_Host </app/schema/user.js

