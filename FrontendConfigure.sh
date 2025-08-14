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

echo -e "$G Starting the Forntend configuration... $N" | tee -a $Log_file
Check_User

echo -e "$G Installing nginx ... $N" | tee -a $Log_file
dnf install nginx -y &>> $Log_file
Validate $? "nginx" "installation"

systemctl enable nginx &>> $Log_file
Validate $? "nginx" "enabling"
systemctl start nginx &>> $Log_file 
Validate $? "nginx" "starting"

rm -rf /usr/share/nginx/html/* &>> $Log_file
Validate $? "Nginx HTML directory" "clearing"

echo -e "$G Downloading frontend files... $N" | tee -a $Log_file
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
Validate $? "Download of frontend.zip" "download"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $Log_file
Validate $? "Unzipping frontend.zip" "unzip"

cp /home/ec2-user/Shell_Script-Practice/expense.conf /etc/nginx/default.d/expense.conf  &>> $Log_file
Validate $? "Nginx configuration" "copying"

echo -e "$G Restarting nginx service... $N" | tee -a $Log_file
systemctl restart nginx &>> $Log_file
Validate $? "nginx service" "restarting"    


echo -e "$G Frontend configuration completed successfully! $N" | tee -a $Log_file
echo -e "$G Log file: $Log_file $N" | tee -a $Log_file