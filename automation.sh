#!/bin/bash
sudo apt update -y
comm=$(dpkg --get-selections | grep apache)
if  [[ $comm == *"apache"* ]]; then
	echo "apache2 is already installed"
else sudo apt-get install apache2
fi

servstat=$(service apache2 status)
if [[ $servstat == *"active (running)"* ]]; then
	echo "server is running"
else  sudo systemctl start apache2
fi

status=$(sudo systemctl status apache2.service)
if [[ $status == *"active (running)"* ]]; then
	echo "service is enabled"
else sudo service apache2 restart
fi

timestamp=$(date '+%d%m%Y-%H%M%S')
myname="arpan"
cd /tmp
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log

s3_bucket="upgrad-arpan"
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

