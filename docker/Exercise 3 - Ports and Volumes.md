# Exercise 3 - Ports and Volumes

In this exercise, you will run an _nginx_ webserver in a container and serve a custom website to the outside world.

The solution to this exercise can be found [here](https://github.wdf.sap.corp/slvi/docker-k8s-training/blob/master/docker/solutions/Solution%20to%20Exercise%203%20-%20Ports%20and%20Volumes.md).

## Step 0: run an NGINX container and connect to it

An official _nginx_ image is provided on Docker Hub. Use the `docker search` command to search for it, `pull` it to your computer and eventually `run` it. Try to connect with your Web-Browser to the VM your nginx container is running on.

**Hint:** The official _nginx_ image is appropriately labeled and features the most stars.

## Step 1: forward NGINX' port

Start a new container and export the port of the _nginx_ webserver to a random port that is chosen by Docker. Use the `docker ps` command to find you which port the webserver is forwarded to and use your web browser to connect to it.

## Step 2: forward NGINX' to a specified port

Within SAP it is more or less standard to let webservers run on port 1080. Start another _nginx_ container but this time, make sure the exposed port of the webserver is forwarded to port 1080 on your host.

**Hint:** You can use `docker inspect` to find out which port is exposed by the image.

Again, use your web browser to connect to your VM, port 1080.

## Step 3: import a volume

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
