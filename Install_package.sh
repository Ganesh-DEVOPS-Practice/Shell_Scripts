#!/bin/bash
uid=$(id -u)
if [ "$uid" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

if [ $# -lt 1 ]; then 
    echo "Usage of file is : $0 <package_name1> <package_name2> ..."
    exit 1
fi  

for package in $@
do 
    dnf list installed $package 
    if [ $? -ne 0 ]; then
        echo "Package $package is not installed. Installing..."
        dnf install $package -y
        if [ $? -eq 0 ]; then
            echo "Package $package installed successfully."
        else
            echo "Failed to install package $package."
        fi
    else
        echo "Package $package is already installed."
    fi
done