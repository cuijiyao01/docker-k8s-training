# Docker container to serve kube config files

Course participants need to get their personal `.kube/config` to get access to the cluster (contains tokens) and with their namespace set as default.

This docker image wraps the content of the `content` directory and serves it with nginx. 

## How to build and run

- First run the script to create all the config files
- Copy the config files to the `content` subdirectory
- Build: `docker build -t k8st-cfg-access .` 
- Run: `docker run -d -p8001:80 k8st-cfg-access:latest`


TODOs
- Wrap the above steps in a script


## How to use by participants

Participants enter the name of their config instead of the `index.html` and thereby download their config file and then store it in `.kube/config`.

Alternative: use curl command
