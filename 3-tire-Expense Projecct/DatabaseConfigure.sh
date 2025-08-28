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

echo -e "$G Starting the Database configuration... $N" | tee -a $Log_file
Check_User
echo -e "$G Installing MySQL server... $N" | tee -a $Log_file
# Install MySQL server
dnf install mysql-server -y &>> $Log_file
Validate $? "MySQL server" "installation"
echo -e "$G Starting MySQL service... $N" | tee -a $Log_file
systemctl start mysqld &>> $Log_file    
Validate $? "MySQL service" "starting"
echo -e "$G Checking MySQL service status... $N" | tee -a $Log_file
systemctl status mysqld &>> $Log_file
Validate $? "MySQL service" "status checking"
echo -e "$G Enabling MySQL service to start on boot... $N" | tee -a $Log_file
systemctl enable mysqld &>> $Log_file
validate $? "MySQL service" "enabling"
mysql -h mysql.ganeshdevops.space -u root -pExpenseApp@1 -e 'show databases;' &>> $Log_file
if [ $? -ne 0 ]; then
    echo -e "$Y Mysql server root password not setup, setting it ... $N" | tee -a $Log_file
    mysql_secure_installation --set-root-pass ExpenseApp@1
    Validate $? "MySQL root password setup" "setting"
else
    echo -e "$G MySQL server root password already set $N" | tee -a $Log_file
fi


echo -e "$G Mysql Server configuration completed successfully! $N" | tee -a $Log_file
echo -e "$G Log file: $Log_file $N" | tee -a $Log_file