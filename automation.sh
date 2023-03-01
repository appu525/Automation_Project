#!/bin/bash
sudo apt update -y
comm=$(dpkg --get-selections | grep apache)
if [[ $comm == *"apache"* ]]; then
        echo "apache2 is already installed"
else sudo apt-get install apache2
fi

servstat=$(service apache2 status)
if [[ $servstat == *"active (running)"* ]]; then
        echo "server is running"
else sudo systemctl start apache2
fi

status=$(sudo systemctl status apache2.service)
if [[ $status == *"active (running)"* ]]; then
        echo "service is enabled"
else sudo systemctl enable apache2
fi


timestamp=$(date '+%d%m%Y-%H%M%S')
myname="arpan"
cd /tmp
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log

s3_bucket="upgrad-arpan"
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

#te=$(ls -t | head -n1 )

te=$(aws s3api list-objects-v2 --bucket ${s3_bucket} --query 'sort_by(Contents, &LastModified)[-1].Key' --output=text)
echo $te
si=$(du -k $te | cut -f1)
echo $si

var1=$(ls /var/www/html | grep inventory.html)
dl=""
if [ $var1 ]; then
        echo  "<br>httpd-logs&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$timestamp&nbsp;&nbsp;&nbsp;&nbsp;tar&nbsp;&nbsp;&nbsp;&nbsp;${si}K" >> /var/www/html/inventory.html

else
        echo "<h4 style="margin-bottom:0px"> Log Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date Created&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;&nbsp;Size</h4>" >> /var/www/html/inventory.html
        echo "<br>httpd-logs&nbsp;&nbsp;&nbsp;&nbsp;$timestamp&nbsp;&nbsp;&nbsp;&nbsp;tar&nbsp;&nbsp;&nbsp;&nbsp;${si}K" >> /var/www/html/inventory.html
fi

gitrepo="Automation_Project"
automation_script="/root/${gitrepo}/automation.sh"
if [ ! -f /etc/cron.d/automation ]; then
    echo "0 0 * * * root ${automation_script}" > /etc/cron.d/automation
fi
