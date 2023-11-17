#!/bin/bash

# arguments
echo -n "Set DB password: "
read DBPASS

REPO="bootcamp-devops-2023"
# verify root user
if [ "$(id -u)" -ne 0 ];
then
  echo "only root user can run this script"
  exit
fi


##comprobar paquetes
echo "Actualizacion de paquetes"

sudo  dnf update

if rpm -q git > /dev/null 2&>1;
then
      echo "git ya esta instaldo"
else
      sudo dnf install git -y
      echo  "instalación git"
fi

#Instalación nginx

if  rpm -q nginx > /dev/null 2&>1;
then
    echo "ya esta instalado el apache2"
else
    sudo dnf install -y nginx
    sudo  dnf install -y php php-cli php-mysqlnd php-mbstring php-zip php-gd php-json php-curl
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo systemctl reload nginx
fi

### validar php
if  rpm -q php > /dev/null 2&>1;
then
        echo "php installed"
else
        echo "installing php"
        sudo dnf install php php-cli php-curl php-mysqlnd php-gd php-opcache php-zip php-intl

fi

### validar  curl
if  rpm -q curl > /dev/null 2&>1;
then
        echo "curl installed"
else
        echo "installing curl"
        sudo dnf install curl -y
fi

# download repository
if [ -d "$REPO" ];
then
        echo "updating repository"
        cd $REPO
        git checkout clase2-linux-bash
        git pull
        cd ..
else
        git clone -b clase2-linux-bash https://github.com/roxsross/$REPO.git
fi

# instalar mysql
if rpm -q mysql > /dev/null 2$>1;
then
   echo "mysql ya esta instalado"
else
   echo "instalando mysql"
   sudo dnf install mysql-server -y
fi
   sudo systemctl start mysqld
   sudo systemctl enable mysqld

   mysql -e "CREATE DATABASE devopstravel;CREATE USER 'codeuser'@'localhost' IDENTIFIED BY '$DBPASS';GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';F
LUSH PRIVILEGES;"

mysql devopstravel < ./$REPO/app-295devops-travel/database/devopstravel.sql


# copy files of the repository to apache folder
cp -r ./$REPO/app-295devops-travel/* /usr/share/nginx/html/


#set passw_db
OLDDB='""'

sudo sed -i 's/\$dbPassword = "";/\$dbPassword =\$DBPASS;/' /usr/share/nginx/html/config.php
sudo systemctl reload nginx