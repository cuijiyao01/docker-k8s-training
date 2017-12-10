# Exercise 3 - Ports and Volumes

In this exercise, you will run an NGINX webserver in a container and server a custom website to the outside world.

## Step 0: run an NGINX container and connect to it

An official NGINX image is provided on docker hub. Use the docker command to `search` for it, `pull` it to your computer and eventually `run` it. Try to connect with your Web-Browser to the VM your nginx container is running on.

**Hint:** The official NGINX image is appropriately labeled and features the most stars.

## Step 1: expose NGINX' port

Start a new container and export the port of the NGINX webserver to port 4000 of your VM. Use the `docker inspect` command to find out which ports are exposed by the NGINX container.

Again, use your webbrowser to connect to your VM, port 4000.

## Step 2: import a volume

Create a directory on your VM. Inside that directory, create a file `index.html` and put some simple HTML into it. Start a new container that bind-mounts this directory to `/usr/share/nginx/html` as a volume so that NGINX will publish your custom HTML file instead of its default message.

**Shortcut:** If you do not want to type your own HTML, just use this:

```html
<html>
<head>
    <title>Custom Website from my container</title>
</head>
<body>
    <h1>This is a custom website.</h1>
    <p>This website is served from my <a href="http://www.docker.com" target="_blank">Docker</a> container.</p>
</body>
</html>
```
