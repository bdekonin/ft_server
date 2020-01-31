FROM debian:buster

#		docker build -t mydockerimage .
# 		docker run --rm --name mydockerfile -p 80:80 -p 443:443 -it mydockerimage

# -y:   During the execition you may get yes/no prompts. With this option is always run the option with yes.
# -it:  Stands for Interactive Terminal

RUN apt-get update -y
RUN apt-get upgrade -y


# Setup - installing the webserver nginx and also installing a package, that is able to download something from a url.
RUN apt-get install nginx wget -y
# Setup - installing neccesary packages for the Mariadb server (Mysql)
RUN apt-get install mariadb-server mariadb-client -y

# PHP - installing neccesary packages for (phpMyAdmin)
RUN apt install -y php7.3 php7.3-fpm php7.3-mysql php-common php7.3-cli \
	php7.3-common php7.3-json php7.3-opcache php7.3-readline php-gd php-mbstring
# PHP - downloads a file from the link givin. wget is used for this.
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz
# PHP - unzips the tar files and moves it to the folder where nginx is also installed.
RUN tar -zxvf phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN mv phpMyAdmin-4.9.0.1-all-languages /var/www/html/phpMyAdmin


# Files - Replaces existing files and replaces the original ones.
COPY srcs/phpMyAdmin/config.inc.php /var/www/html/phpMyAdmin/config.inc.php
COPY srcs/phpMyAdmin/phpMyAdmin.conf /etc/nginx/conf.d/phpMyAdmin.conf


# MYSQL - Creating a user called 'admin'. giving them all rights
RUN service mysql start && \
    mysql -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';" && \
    mysql -e "GRANT ALL PRIVILEGES ON * . * TO 'admin'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;"
# MYSQL - Add the user and grant permission to phpMyAdmin’s database.
RUN service mysql start && \
    mysql -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'admin'@'localhost' IDENTIFIED BY 'password';" && \
    mysql -e "FLUSH PRIVILEGES;"


# PHP - Creating a tmp directory for phpMyAdmin and then change the permission.
RUN mkdir /var/www/html/phpMyAdmin/tmp
RUN chmod 777 /var/www/html/phpMyAdmin/tmp
# PHP - Set the ownership of phpMyAdmin directory.
RUN chown -R www-data:www-data /var/www/html/phpMyAdmin


# MYSQL - Creating a database user and login to phpMyAdmin with that user.
RUN service mysql start && \
    mysql -e "CREATE DATABASE app_db;" && \
    mysql -e "GRANT ALL PRIVILEGES ON app_db.* TO 'admin'@'localhost' IDENTIFIED BY 'password';" && \
	mysql -e "FLUSH PRIVILEGES;"


# SSL - Downloading a tool that makes locally trusted certificates.
RUN wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-arm
# SSL - Makes the mkcert an executable.
RUN chmod +x mkcert-v1.4.1-linux-arm
RUN mv mkcert-v1.4.1-linux-arm /usr/local/bin/mkcert
RUN /usr/local/bin/mkcert -install
# SSL - Generates a certificate/certificate key for the domain localhost.
RUN mkcert localhost


# Files - Moving our configured nginx.conf to the container.
COPY srcs/nginx/nginx.conf /tmp/default
RUN mv /tmp/default /etc/nginx/sites-available/default
# Files - Moving an reconfigured index.html and replaces it with the existing one.
COPY srcs/nginx/index.html /tmp/index.nginx-debian.html
RUN mv /tmp/index.nginx-debian.html /var/www/html/index.nginx-debian.html


# Expose - nginx (http)
EXPOSE 80
# Expose - SSL Certificate (https)
EXPOSE 443


CMD service nginx start && service mysql start && service php7.3-fpm start && tail -f /dev/null
