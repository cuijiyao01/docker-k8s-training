# Solution to Exercise 2 - Ports and Volumes

In this exercise, you will run an _nginx_ webserver in a container and server a custom website to the outside world.

## Step 0: run an NGINX container and connect to it

Either go to [hub.docker.com](https://hub.docker.com) and search for *[nginx](https://hub.docker.com/_/nginx/)* or use `docker search`.

```bash
$ docker search nginx
NAME                                      DESCRIPTION                                     STARS    OFFICIAL   AUTOMATED
nginx                                     Official build of Nginx.                        8564     [OK]
jwilder/nginx-proxy                       Automated Nginx reverse proxy for docker c...   1335                [OK]
richarvey/nginx-php-fpm                   Container running Nginx + PHP-FPM capable ...   547                 [OK]
jrcs/letsencrypt-nginx-proxy-companion    LetsEncrypt container to use with nginx as...   367                 [OK]
kong                                      Open-source Microservice & API Management ...   187      [OK]
[...]
```
In this example output, the *nginx* image we are looking for is on the first line.

Pull the image to your computer:

```bash
$ docker pull nginx
```

And run the image in detached mode:

```bash
$ docker run -d --name ex3nginx nginx
```

Now open a browser in your VM (like Firefox or Chrome) and type in `http://localhost:80` - you will get no reply as the container is not exposed yet.

Stop and remove your container:

```bash
$ docker stop ex3nginx
$ docker rm ex3nginx
```

## Step 1: forward NGINX' port

Start a new container and export the port of the _nginx_ webserver to a random port that is chosen by Docker.

```bash
$ docker run -d -P --name ex31nginx nginx
```

Use the `docker ps` command to find you which port the webserver is forwarded to. The result will look like this:

```bash
$ docker ps
CONTAINER ID    IMAGE    COMMAND                  CREATED           STATUS          PORTS                   NAMES
44b447735dc1    nginx    "nginx -g 'daemon ..."   3 seconds ago     Up 2 seconds    0.0.0.0:32768->80/tcp   ex31nginx
```

In this example, port 80 of the container was forwarded to port 32768 of the Docker host (this number might be different in your case). Use your webbrowser again and direct it to
`http://localhost:<your port number>` (so to `http://localhost:32768` in this example). This time you will see *nginx'* default landing page.

Stop and remove your container:

```bash
$ docker stop ex31nginx
$ docker rm ex31nginx
```

## Step 2: forward NGINX' to a specified port

Start another _nginx_ container but this time, make sure the exposed port of the webserver is forwarded to port 1080 on your host.

```bash
$ docker run -d -p 1080:80 --name ex32nginx nginx
```

You can now connect to `http://localhost:1080` with your web browser and see _nginx'_ default landing page.

Stop and remove your container.

```bash
$ docker stop ex32nginx
$ docker rm ex32nginx
```

**Hint:** You can use `docker inspect` to find out which port is exposed by the image like this. The exposed port is clearly visible:

```
$ docker inspect nginx | grep -2 ExposedPorts
"AttachStdout": false,
"AttachStderr": false,
"ExposedPorts": {
    "80/tcp": {}
},
--
"AttachStdout": false,
"AttachStderr": false,
"ExposedPorts": {
    "80/tcp": {}
},
```


## Step 3: import a volume

Create a directory on your VM. Inside that directory, create a file `index.html` and put some simple HTML into it.

```bash
$ mkdir `pwd`/nginx-html
$ cat << _EOF > `pwd`/nginx-html/index.html
<html>
<head>
    <title>Custom Website from my container</title>
</head>
<body>
    <h1>This is a custom website.</h1>
    <p>This website is served from my <a href="http://www.docker.com" target="_blank">Docker</a> container.</p>
</body>
</html>
_EOF
```

Start a new container that bind-mounts this directory to `/usr/share/nginx/html` as a volume.

```bash
$ docker run -d -p 1081:80 -v `pwd`/nginx-html:/usr/share/nginx/html --name ex33nginx nginx
```

Now use your browser once again to go to `http://localhost:1081` - you will now see the webpage you just created.

Stop and remove your container once you are finished.

```bash
$ docker stop ex33nginx
$ docker rm ex33nginx
```
