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

cp /home/cetos/manacars/mongodb.repo  /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? " Copying mongodb repo"

dnf install mongodb-org -y  &>> $LOGFILE

VALIDATE $? " Installing mongodb"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? " Enable mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "Start mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? " allowed traffic"

systemctl restart mongod &>> $LOGFILE
 VALIDATE $? " Restart mongodb"

 s

