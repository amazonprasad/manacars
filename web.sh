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


dnf install nginx -y  &>> $LOGFILE

VALIDATE $? " Install nginx"

systemctl enable nginx  &>> $LOGFILE

VALIDATE $? "Enable nginx"

systemctl start nginx  &>> $LOGFILE

VALIDATE $? "start Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE 

VALIDATE $? " remove default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>> $LOGFILE

VALIDATE $? " Downloading web files"

cd /usr/share/nginx/html &>> $LOGFILE 

VALIDATE $? "change directory"


unzip -o /tmp/frontend.zip  &>> $LOGFILE 

VALIDATE $? "Unzip the files"

cp /home/centos/manacars/roboshop.conf /etc/nginx/default.d/roboshop.conf

VALIDATE $? " Copying files"

systemctl restart nginx  

VALIDATE $? "restart nginx"

