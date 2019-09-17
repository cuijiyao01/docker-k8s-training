# Optional Exercise 4 - Dockerfiles Extended: Multi-stage build

In this exercise, you will create a Dockerfile consisting of two stages. Within a build stage you will compile a go-based web app. Next, copy the binary to run stage, which consists of a minimal set of libs only. (and yes, you could also link everything statically and have an image with the binary only). 

The app is a simple webserver providing view and edit functionality for "wiki pages" and is based on this [tutorial](https://golang.org/doc/articles/wiki/). It serves on port 8080, renders web pages based on templates parsed from files and can persist pages on the filesystem.

The structure looks like this
```
/app
├── wiki                --> executable
├── tmpl                --> template for page rendering
│   ├── edit.html
│   └── view.html
└── data                --> location to store pages as txt files
│   ├── somepage.txt
```

## Step 0: Setting up your build context

Create an empty directory on your VM that will be your build context. Download the `wiki.go` file and create a folder called `tmpl` where you place the `edit.html` and `view.html` template files.

```bash
wget -O edit.html https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/edit.html
wget -O view.html https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/view.html
wget -O wiki.go https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/wiki.go
```

## Step 1: Creating the Dockerfile

Create an new Dockerfile that starts `FROM golang:1.12-alpine as builder`. Note, the `as builder` extension - it allows you to reference files present at this stage and copy them over to another stage.
To prepare for the build, change the `WORKDIR` to `/go/src/` and `COPY` the `wiki.go` file over.

## Step 2: Compile wiki.go
The next step should be to compile the go binary. 

`RUN go build wiki.go`

The result should be a binary called `wiki`.

## Step 3: Add another stage
Multi-stage in the context of Docker means, you are allowed to have more than one line with a `FROM` keyword. Let's make use of this to create a new stage:

`FROM alpine:3.9`

This will setup a completely new image which is initially independent of the previous. Since you want to get some credit for what you are doing, put a `LABEL maintainer="<your C/D/I-number>"` in there.

## Step 4: Prepare runtime
Let's create an environment that reflects the file system structure mentioned in the beginning. Use the `RUN` directive to `mkdir` the directories. Also you don't want to run a simple app like the wiki with root permissions. Create a new `appuser` with this command:

`adduser -S -D -H -h /app appuser`

## Step 5: Get the executable 
Data from earlier stages can be consumed with `COPY --from=<previous stage name>` commands. Move the `wiki` executable to the runtime stage and place it directly in the `/app/` directory.

## Step 6: Adapt the environment
So far all directories / files are owned by the `root` user. Time to change that and grant the `appuser` access to the required parts of the filesystem. Since everything relevant is stored within `/app` you can `RUN` this command to do the changes: `chown -R appuser /app`

Now you can user the `USER` directive to change to `appuser`. Also the wiki expects to find files relative to its location. So you have to set the `WORKDIR` accordingly.

What's still missing? Of course your image should `EXPOSE` a port and should have `CMD` that is invoked upon container start. 
The wiki app is listening on port 8080.

## Step 7: Build the images

Use the `docker build` command to build your image. Tag it along the way so you can find it easily.

## Step 8: Run your image

Run the image in detached mode, create a port forwarding from port 8080 in the container to some port on your host and connect with your web browser to it.
