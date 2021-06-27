#! /bin/bash

# Shell script to install apache/mysql/php/wordpress into an EC2 instance of Amazon AMI Linux.
# Step 1: Create an AWS EC2 instance
# Step 2: ssh in like: ssh -v -i wordpress.pem ec2-user@ec2-54-185-74-0.us-west-2.compute.amazonaws.com
# Step 3: Run this as root/superuser, do sudo su
#sudo su -
#apt-get update -y
echo "Shell script to install apache/mysql/php/wordpress into an EC2 instance of Amazon AMI Linux."
echo "Please run as root, if you're not, choose N now and enter 'sudo su' before running the script."
echo "Run script? (y/n)"
sudo su
read -e run
if [ "$run" == n ] ; then
echo “chicken...”
exit
else
apt-get update -y
# we'll install 'expect' to input keystrokes/y/n/passwords
apt-get -y install expect 

# Install Apache
apt-get -y install apache2

# Start Apache
#service apache2 start

# Install PHP
apt-get install php php-mysql php-common php-gd php-cli -y

# Restart Apache
#service apache2 restart
#read -p 'wordpress_db_name [wp_db]: ' wordpress_db_name
#read -p 'db_root_password [only-alphanumeric]: ' db_root_password
#echo

# Install MySQL
#export DEBIAN_FRONTEND="noninteractive"  
#debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_root_password"  
#debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_root_password"  
apt-get install mysql-server mysql-client -y

# Start MySQL
systemctl restart mysql

# Create a database named blog
## Configure WordPress Database  

systemctl restart mysql;

# Secure database
# non interactive mysql_secure_installation with a little help from expect.

SECURE_MYSQL=$(expect -c "
 
set timeout 10
spawn mysql_secure_installation
 
expect \"Enter current password for root (enter for none):\"
send \"\r\"
 
expect \"Change the root password?\"
send \"y\r\"

expect \"New password:\"
send \"password\r\"

expect \"Re-enter new password:\"
send \"password\r\"

expect \"Remove anonymous users?\"
send \"y\r\"
 
expect \"Disallow root login remotely?\"
send \"y\r\"
 
expect \"Remove test database and access to it?\"
send \"y\r\"
 
expect \"Reload privilege tables now?\"
send \"y\r\"
 
expect eof
")
 
echo "$SECURE_MYSQL"

## Configure WordPress Database
mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE wordpress;
CREATE USER 'vijay'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wordpress.* TO 'vijay'@'localhost';
FLUSH PRIVILEGES;
quit;
MYSQL_SCRIPT
# Change directory to web root
cd /var/www/html/

apt-get install unzip wget -y
# Download Wordpress
wget http://wordpress.org/latest.zip

# Extract Wordpress
unzip latest.zip

# Rename wordpress directory to blog
mv wordpress blog

# Change directory to blog
cd /var/www/html/blog/

# Create a WordPress config file 
cp -r wp-config-sample.php wp-config.php

#set database details with perl find and replace
sed -i "s/database_name_here/wordpress/g" /var/www/html/blog/wp-config.php
sed -i "s/username_here/vijay/g" /var/www/html/blog/wp-config.php
sed -i "s/password_here/password/g" /var/www/html/blog/wp-config.php
#sed -i "s/localhost/localhost/g" /var/www/html/blog/wp-config.php
#create uploads folder and set permissions
mkdir wp-content/uploads
chmod 777 wp-content/uploads
chown www-data:www-data -R /var/www/html/blog/
#remove wp file
rm -rf  /var/www/html/latest.zip
#rm -rf /var/www/html/index.html
systemctl restart apache2
#echo "Ready, go to http://'your ec2 url'/blog and enter the blog info to finish the installation."
username
fi
