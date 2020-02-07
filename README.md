# ft_server - @ Codam Coding College
This project will give us the basic understanding of Docker. This Dockerfile will allow you to install a complete web server, included with a MYSQL database, phpMyAdmin and also WordPress.

#### What is docker?
Docker is a tool designed to make it easier to create, deploy, and run applications by using containers. Containers allow a developer to package up an application with all of the parts it needs, such as libraries and other dependencies, and ship it all out as one package. Read more at https://blog.usejournal.com/what-is-docker-in-simple-english-a24e8136b90b

#### How do I run it?
First of make sure you have Docker on your computer before going further. If this is not the case lets continue, we first need to build an image. We can do this by running `docker build -t mydockerimage .`

The `-t` gives it an tag, which in this case is called `mydockerimage`.
and we use the `.`to select a location, which we use in this case to select the root folder.

So after some time the build should be finished and has stored it somewhere on the machine.
We need to run it now but we will use some parameters to make it easier for us.
1. `--rm` This automatically removes the container when you exit it. The best way to use this is with the combination of the `-it` and parameter.

2. `--name` I use this because I want the container renamed to something that I understand. If you do not do this the container name will be a random string.

3. `-it` This stands for integrated terminal. and with this you can manoeuvre through the container.

So this now explained this will be the command for you to run it.
`docker run --rm --name mydockerfile -p 80:80 -p 443:443 -it mydockerimage`
This will run the container and you can go to e.g localhost/wp-admin to login into the wordpress website.
