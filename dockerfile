FROM debian:buster

#		docker build -t mydockerimage .
# 		docker run --rm --name mydockerfile -p 80:80 -p 443:443 -it mydockerimage
# 		docker ps shows running containers
# 		docker rmi removes images
# 		docker rm removes container
# 		-it interactieve terminal
# 		docker exec -it mydockerfile bash  

# -y:   During the execition you may get yes/no prompts. With this option is always run the option with yes.
# -it:  Stands for Interactive Terminal

RUN apt-get update -y
RUN apt-get upgrade -y

# Setup - installing the webserver nginx and also installing a package, that is able to download something from a url.
RUN apt-get install nginx wget -y


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

CMD service nginx start && tail -f /dev/null
