# Solution to optional Exercise 4 - Dockerfiles Extended: Multi-stage build

In this exercise, you will create a Dockerfile consisting of two stages. Within a build stage you will compile a go-based web app. Next, copy the binary to run stage, which consists of a minimal set of libs only. (and yes, you could also link everything statically and have an image with the binary only). 

The app is a simple web server providing view and edit functionality for "wiki pages" and is based on this [tutorial](https://golang.org/doc/articles/wiki/). It serves on port 8080, renders web pages based on templates parsed from files and can persist pages on the filesystem.

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

## Steps 1 to 6: Create the Dockerfile

Create the following Dockerfile in your build context.

```Dockerfile
# builder stage - based on golang image
FROM golang:1.12-alpine as builder

# change current directory to go source path
WORKDIR /go/src

# copy the code into the image
COPY wiki.go /go/src/wiki.go

# build the binary
RUN go build wiki.go

# app exec stage based on small alpine image
####################################
# separate & new image starts here!#
####################################
FROM alpine:3.9

# prepare file system & create a new user
RUN mkdir -p /app/data /app/tmpl && adduser -S -D -H -h /app appuser

# copy edit & view templates into image
COPY tmpl/* /app/tmpl/

# copy the compiled binary from the previous stage into current stage
COPY --from=builder /go/src/wiki /app/wiki

# change ownership of everything in /app
RUN chown -R appuser /app

# change from root to appuser
USER appuser

# the app expects to find directories & files relative to the current directory
WORKDIR /app

# expose app port 
EXPOSE 8080

# set default command to launch the wiki application upon container start
CMD ["/app/wiki"]
```

## Step 9: Build the images

Build and tag the image. Again, use your participant-ID as release tag.

```bash
docker build -t go-wiki:part-0001 .
```

## Step 10: Run your image

Run the image im detached mode, create a port forwarding from port 80 in the container to port 1081 on your host and connect with your webbrowser to it.

```bash
docker run -d -p 8080:8080 go-wiki:part-0001
```
