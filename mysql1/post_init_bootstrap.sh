#!/bin/bash

echo "RUNNING BOOTSTRAP"

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
