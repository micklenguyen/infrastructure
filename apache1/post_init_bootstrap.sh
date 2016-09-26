#!/bin/bash

echo "RUNNING BOOTSTRAP"

# Install Apache
sudo yum -y install httpd

# Configure Apache to serve web content from all home directories
sudo sed -i -e 's/    UserDir disabled/UserDir enabled unixmenuser/g' /etc/httpd/conf.d/userdir.conf
sudo sed -i -e 's/    #UserDir public_html/     UserDir public_html/g' /etc/httpd/conf.d/userdir.conf
sudo sed -i -e 's/    AllowOverride FileInfo AuthConfig Limit Indexes/ /g' /etc/httpd/conf.d/userdir.conf
sudo sed -i -e 's/    Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec/Options Indexes Includes FollowSymLinks/g' /etc/httpd/conf.d/userdir.conf
sudo sed -i -e 's/    Require method GET POST OPTIONS/Require all granted/g' /etc/httpd/conf.d/userdir.conf

# Restart Apache
sudo systemctl restart httpd.service

# Create "Hello World" page for 2 users
sudo useradd user1
sudo useradd user2
sudo mkdir /home/user1/public_html
sudo mkdir /home/user2/public_html
sudo chmod 711 /home/user1
sudo chmod 711 /home/user2
sudo chown user1:user1 /home/user1/public_html
sudo chown user2:user2 /home/user2/public_html
sudo chmod 755 /home/user1/public_html
sudo chmod 755 /home/user2/public_html

sudo setsebool -P httpd_enable_homedirs true 
sudo chcon -R -t httpd_sys_content_t /home/user1/public_html
sudo chcon -R -t httpd_sys_content_t /home/user2/public_html

# Create page by editing index.html and change its permissions
sudo touch /home/user1/public_html/index.html
sudo chmod 644 /home/user1/public_html/index.html
sudo echo "THIS IS USER1'S PAGE" >> /home/user1/public_html/index.html

sudo touch /home/user2/public_html/index.html
sudo chmod 644 /home/user2/public_html/index.html
sudo echo "THIS IS USER2'S PAGE" >> /home/user2/public_html/index.html

# Edit the Homepage
sudo touch /var/www/html/index.html
sudo echo "THIS IS THE HOMEPAGE" >> /var/www/html/index.html

# Startup Apache at Boot
sudo systemctl enable httpd

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
