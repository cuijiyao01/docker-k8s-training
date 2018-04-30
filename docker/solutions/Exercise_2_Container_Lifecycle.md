# Container Lifecycle

## Step 0
``` 
docker run -it busybox
top
``` 
will produce something like:
``` 

  PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
    1     0 root     S     1248  0.0   1  0.0 sh
   10     1 root     R     1240  0.0   0  0.0 top
``` 

## Step 1
To detach from container use `Ctrl+p` and then `Ctrl+q`. You may then do `clear` to clean your terminal.  
When doing `docker ps`, you'll get something like:
``` 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
XXXXXXXXXXXX        busybox             "sh"                5 minutes ago       Up 5 minutes                            silly_name
``` 

## Step 2
Start another shell into the container by doing `docker exec -it <your container ID or Silly_Name> /bin/sh`. (e.g. `docker exec -it 567d71edcab0 /bin/sh`).  
Perform `ps` or again `top` to see the processes that run in there.  
Leave `top` by pushing the key `q`, and detach from container using `Ctrl+p` and then `Ctrl+q`.  

## Step 3
You perform: `docker attach <your container ID or Silly_Name> /bin/sh` (e.g. `docker attach 567d71edcab0`) and you'll see that you're still running the `top` command from Step 0 you had on screen before performing Step 1.  
As per [documentation](https://docs.docker.com/engine/reference/commandline/attach/) `docker attach` will always connect to `ENTRYPOINT/CMD` process; That is, the special process running with PID 1. So no matter how often you perform `docker attach`, you'll always get the terminal from Step 0.  

## Step 4
`docker logs <your container ID or Silly_Name>`  displays the logs present at the time of execution as [documented](https://docs.docker.com/engine/reference/commandline/logs/). In our case it displays the `top` output, and if you run this command several times while container still runs, you'll see the output changes.  

## Step 5
Run: `docker run -d nginx`.  
Perform `docker ps` to see the running containers.  
Perform `docker stop <your container ID or Silly_Name>` (e.g. `docker stop 94cb514de45e`) to end your container.  

# Step 6
Unless you want to use the command `docker rm $(docker ps -aq)` (which REALLY deletes ALL the containers - and this might be dangerous !), you may also perform: `docker ps -a` to see a list with all the running & exited containers and then delete multiple of them with one command: `docker rm <container1> <container2> <containerN>`.  
