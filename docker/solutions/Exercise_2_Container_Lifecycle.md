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
Leave `top` by pushing the key `q`, and leave this shell by calling `exit`.  
