#!/bin/bash

echo "RUNNING BOOTSTRAP"

# Install LAMP
# A "LAMP" stack is a group of open source software that is typically installed together to enable a server to host dynamic websites and web apps. This term is actually an acronym which represents the Linux operating system, with the Apache web server. The site data is stored in a MySQL database (using MariaDB), and dynamic content is processed by PHP.
# https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-centos-7

# STEP ONE - INSTALL APACHE
sudo yum install -y httpd

# Start Apache
sudo systemctl start httpd.service

# Enable Apache to start on boot
sudo systemctl enable httpd.service


# STEP TWO - INSTALL MYSQL

# Yum Update
sudo yum update -y

# Install wget
sudo yum install -y wget

# Install rpm
sudo yum install -y rpm

# MySQL must be installed from the community repository. Download and add the repository, then update.
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum update -y

# Install mySQL
sudo yum install -y mysql-server
sudo systemctl start mysqld

# Configure mySQL to auto restart on boot
sudo systemctl enable mysqld

# Steps needed after
# Create a User within mySQL
# Create a database

# Now that our MySQL database is running, we want to run a simple security script that will remove some dangerous defaults and lock down access to our database system a little bit. Start the interactive script by running:

# $ sudo mysql_secure_installation

# The prompt will ask you for your current root password. Since you just installed MySQL, you most likely won’t have one, so leave it blank by pressing enter. Then the prompt will ask you if you want to set a root password. Go ahead and enter Y, and follow the instructions:

# Login into mySQL

# $ mysql -u root -p

# In the example below, testdb is the name of the database, testuser is the user, and password is the user’s password.

# $ create database testdb;
# $ create user 'testuser'@'localhost' identified by 'password';
# $ grant all on testdb.* to 'testuser' identified by 'password';

# You can shorten this process by creating the user while assigning database permissions:

# $ create database testdb;
# $ grant all on testdb.* to 'testuser' identified by 'password';

# Then exit MySQL.

# $ exit


# STEP THREE - INSTALL PHP

# Install php and php-mysql
sudo yum install -y  php php-mysql

# Restart Apache
sudo systemctl restart httpd.service




# INSTALL NAGIOS

# Install Build Dependencies
sudo yum install -y gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel xinetd unzip

# Create Nagios User and Group
sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios

# Install Nagios Core
cd ~
curl -L -O https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.2.1.tar.gz

# Extract Nagios
sudo tar xvf nagios-*.tar.gz

# Change Directory
cd nagios-*

# Configure it with this command
sudo ./configure --with-command-group=nagcmd

# Compile Nagios
sudo make all

# Run these make commands to install Nagios, init scripts, and sample configuration files
sudo make install
sudo make install-commandmode
sudo make install-init
sudo make install-config
sudo make install-webconf

# In order to issue external commands via the web interface to Nagios, we must add the web server user, apache, to the nagcmd group
sudo usermod -G nagcmd apache

# Install Nagios Plugins
cd ~
sudo curl -L -O http://nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz

# Extract Nagios Plugins archive
sudo tar xvf nagios-plugins-*.tar.gz

# Change to the extracted directory
cd nagios-plugins-*

# Before building Nagios Plugins, we must configure it. Use this command:
sudo ./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl

# Compile Nagios Plugins
sudo make

# Then install it:
sudo make install

# Install NRPE
cd ~
curl -L -O http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz

# Extract the NRPE archive
tar xvf nrpe-*.tar.gz

# Change to the extracted directory
cd nrpe-*

# Configure NRPE
sudo ./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu

# Build and install NRPE and its xinetd startup script
make all
sudo make install
sudo make install-xinetd
sudo make install-daemon-config

# Modify the only_from line by adding the private IP address of the your Nagios server to the end
sudo sed -i -e 's/only_from       = 127.0.0.1/only_from       = 127.0.0.1 192.168.50.2/g' /etc/xinetd.d/nrpe

# Restart the xinetd service to start NRPE
sudo service xinetd restart

# Configure Nagios

# Organize Nagios Configuration by uncommenting this
sudo sed -i -e 's/#cfg_dir=\/usr\/local\/nagios\/etc\/servers/cfg_dir=\/usr\/local\/nagios\/etc\/servers/g' /usr/local/nagios/etc/nagios.cfg

# Create the directory that will store the configuration file for each server
sudo mkdir /usr/local/nagios/etc/servers

# Configure Nagios Contacts

# Replace email with your own
sudo sed -i -e 's/nagios@localhost/mnguyen@onekingslane.com/g' /usr/local/nagios/etc/objects/contacts.cfg

# Configure check_nrpe Command
# Add a new command to our Nagios configuration
sudo echo "define command{" >> /usr/local/nagios/etc/objects/commands.cfg
sudo echo "        command_name check_nrpe" >> /usr/local/nagios/etc/objects/commands.cfg
sudo echo "        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$" >> /usr/local/nagios/etc/objects/commands.cfg
sudo echo "}" >> /usr/local/nagios/etc/objects/commands.cfg
# This allows you to use the check_nrpe command in your Nagios service definitions

# Configure Apache

# Install expect
sudo yum install -y expect

# Create create_nagios_user.expect heredoc
cat << EOF > /tmp/create_nagios_user.expect
#!/usr/bin/expect

spawn "/tmp/create_nagios_user_command.sh"
expect "New password:"
send "password\n"
expect "Re-type new password:"
send "password\n"

interact
EOF

# Create create_nagios_user_command heredoc
cat << EOF > /tmp/create_nagios_user_command.sh
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
EOF

# Make them execuable
sudo chmod +x /tmp/create_nagios_user.expect /tmp/create_nagios_user_command.sh

# Use htpasswd to create an admin user, called "nagiosadmin", that can access the Nagios web interface

# Call the expect command
sudo /tmp/create_nagios_user.expect

sleep 5

# Nagios is ready to be started. Let's do that, and restart Apache
cd ~
sudo systemctl start nagios
sudo systemctl restart httpd.service

# To enable Nagios to start on server boot
sudo chkconfig nagios on


# Add Color to Prompt
sudo echo "# Adds different color prompt for root" >> /etc/bashrc
sudo echo "" >> /etc/bashrc
sudo echo "CURRENTUSER=\`whoami\`" >> /etc/bashrc
sudo echo "if [ \"\$CURRENTUSER\" = \"root\" ]; then" >> /etc/bashrc
sudo echo "        PS1=\"\\[\$(tput bold)\\]\\e[0;41m[\\u@\\h \\W]\\$ \\e[m \"" >> /etc/bashrc
sudo echo "else" >> /etc/bashrc
sudo echo "        case \"\$HOSTNAME\" in" >> /etc/bashrc
sudo echo "                *) PROMPT_COLOR=\"[\\u@\\h \\W]\\$ \"" >> /etc/bashrc
sudo echo "        esac" >> /etc/bashrc
sudo echo "        PS1=\${PROMPT_COLOR}" >> /etc/bashrc
sudo echo "fi" >> /etc/bashrc


# Create expect file heredoc
cat << EOF > /tmp/mysql_secure_installation_and_add_db.expect
#!/usr/bin/expect

spawn "/tmp/mysql_secure_installation.sh"
expect "Enter current password for root (enter for none):"
send "\n"
expect "Set root password? [Y/n]"
send "Y\n"
expect "New password:"
send "password\n"
expect "Re-enter new password:"
send "password\n"
expect "Remove anonymous users? [Y/n]"
send "Y\n"
expect "Disallow root login remotely? [Y/n]"
send "Y\n"
expect "Remove test database and access to it? [Y/n]"
send "Y\n"
expect "Reload privilege tables now? [Y/n]"
send "Y\n"

interact
EOF

# Create mysql_secure_installation heredoc
cat << EOF > /tmp/mysql_secure_installation.sh
sudo mysql_secure_installation
EOF

# Make them execuable
sudo chmod +x /tmp/mysql_secure_installation_and_add_db.expect /tmp/mysql_secure_installation.sh

# Use htpasswd to create an admin user, called "nagiosadmin", that can access the Nagios web interface

# Call the expect command
sudo /tmp/mysql_secure_installation_and_add_db.expect






