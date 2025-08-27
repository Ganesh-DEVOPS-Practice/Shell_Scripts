#!/bin/bash
Log_folder="/var/log/expense_project"
File_name=$(echo $0 | cut -d "." -f1)
Time_stamp=$(date +%Y-%m-%d_%H:%M:%S)
Log_file="$Log_folder/$File_name-$Time_stamp.log"
mkdir -p $Log_folder

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

User_ID=$(id -u)
Check_User(){
    if [ $User_ID -ne 0 ]; then
        echo -e "$R This script must be run as root. Please use sudo.$N"
        exit 1
    fi
}

Validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$R got error while $3 of $2 $N , $Y Please check the log file: $Log_file $N"
        exit 1
    else
        echo -e "$G $3 $2 successfully $N" | tee -a $Log_file
    fi
}

echo -e "$G Starting the Backend configuration... $N" | tee -a $Log_file
Check_User

echo -e "$G Installing Nodejs:20 ... $N" | tee -a $Log_file
dnf module disable nodejs -y &>> $Log_file
Validate $? "Nodejs:20" "module disabling"
dnf module enable nodejs:20 -y &>> $Log_file
Validate $? "Nodejs:20" "module enabling"
dnf install nodejs -y &>> $Log_file
Validate $? "Nodejs:20" "installation"

id expense &>> $Log_file
if [ $? -ne 0 ]; then
    echo -e "$Y User 'expense' does not exist, creating it... $N" | tee -a $Log_file
    useradd expense &>> $Log_file
    Validate $? "User 'expense'" "creation"
else
    echo -e "$G User 'expense' already exists $N" | tee -a $Log_file
fi

mkdir -p /app
Validate $? "Directory '/app'" "creation"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "backend.zip" "download"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>> $Log_file
Validate $? "Unzipping backend.zip" "unzip"

npm install &>> $Log_file

cp /root/Shell_Script-Practice/backend.service /etc/systemd/system/backend.service &>> $Log_file
Validate $? "Copying backend.service" "copy"

dnf install mysql -y &>> $Log_file
Validate $? "MySQL client" "installation"
mysql -h mysql.ganeshdevops.space -u root -pExpenseApp@1 < /app/schema/backend.sql &>> $Log_file
Validate $? "MySQL schema" "import"

systemctl daemon-reload &>> $Log_file
Validate $? "Systemd daemon reload" "reload"    

systemctl enable backend &>> $Log_file
Validate $? "Enabling backend service" "enable"

systemctl restart backend &>> $Log_file
Validate $? "Restarting backend service" "restart"

systemctl status backend &>> $Log_file
Validate $? "Checking backend service status" "status checking" 

echo -e "$G Backend configuration completed successfully! $N" | tee -a $Log_file
echo -e "$G Log file: $Log_file $N" | tee -a $Log_file