#!/bin/bash
DATE=$(date +%F)
SCRIPT_NAME=$0
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log
IDUSER=$(id -u)
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

VALIDATE $? "Disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enable nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? " Installin =g nodejs"

id=roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop 
    echo -e " $G Roboshop user creation $N"
else 
    echo -e " Roboshop user already exists $Y SKIPPING $N"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? " disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? " enable nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Install nodejs"

id=roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop 
    echo -e " $G Roboshop user creation $N"
else 
    echo -e " Roboshop user already exists $Y SKIPPING $N"
fi

mkdir -p /app 

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip  &>> $LOGFILE

VALIDATE $? " Downloading cart files"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? " Unzip the files"

cd /app 

npm install &>> $LOGFILE

VALIDATE $? "Install npm"

cp /home/centos/manacars/cart.service /etc/systemd/system/cart.service

VALIDATE $? "Copying the files"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reload"

systemctl enable cart  &>> $LOGFILE

VALIDATE $? "enable cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Start cart"





