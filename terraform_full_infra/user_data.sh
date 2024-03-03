#! /bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat << EOF > /var/www/html/index.html
Boker tov IP $myip
version 3
EOF

systemctl start httpd
systemctl enable httpd
