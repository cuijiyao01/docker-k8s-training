# [MicroK8s](https://microk8s.io/)

Instead of using a hosted Kubernetes cluster you may use [MicroK8s](https://microk8s.io/). MicroK8s is one option to run a Kubernetes system within your [training VM](https://github.wdf.sap.corp/cloud-native-dev/k8s-training-vm). 

The following shell scripts may help you setting up a microk8s system that is configured to support most of the excercises. 

- install.sh: Install microk8s with some addons within your VM. After calling this script the first time, reboot your VM. The script adds the current user to a Group, which becomes active after reboot.
- set-kube-config.sh: Creates a `kube.config` file. This allows you to use kubectl in combination with microk8s. This script does not overwrite the default `kube.config` file but creates the file `$HOME/.kube/config-microk8s`. Therefore the environment variable `KUBECONFIG` needs to refer to the correct config. If you use `source set-kube-config.sh`, the script will set the einvironment for you.
- dashboard.sh: Starts the dashboard of your microk8s.  The script write a token to the console. Copy this token into the logon screen of the Kubernetes dashboard.
- remove.sh: Uninstall microk8s.

# Exercises

For most execercises it does not matter if you use a hosted kubernetes system or MicroK8s. Exeception to this are mentioned in the following paragraphs.

## [Exercise 4 - Services](../kubernetes/exercise_04_services.md)

MicroK8s does not support services of type LoadBalancer. As a workaround the script microk8s/install.sh deploys a controler that copies the property clusterIP into the status.LoadBalancer.ingress array. Using this workaround, a service of type LoadBalancer will work within MicroK8s almost the same way as it would work with a hosted Kubernetes system.

## [Excercise 7 - Ingress](../kubernetes/exercise_07_ingress.md)

MicroK8s comes with an ingress addon. The script microk8s/install.sh enabled this addon. The addon controler listens on localhost port 80.Consequently, use the hostname localhost for this exercise. You may also have a look at the solution "07_ingress_mircok8s.yaml". 

If you like to try ingresses with different host names you may use hostnames following this schema: \<any hostname segement\>.127.0.0.1.xip.io. For more details you check [xip.io](xip.io).

## [Excercise 9 - Network Policy](../kubernetes/exercise_09_network_policy.md)

The exercise shows how to whithelist the IP addresses of the originating SAP networks. As you would need to test the service out of your VM, you need to adapt this excercise to your local setup. You may use the solution [09_network_policy_ingress-microk8s.yaml](09_network_policy_ingress-microk8s.yaml).

In case of problems, you may use [ingress-demo.yaml](ingress-demo.yaml) to check the requesting IP.

`````
kubectl apply -f ingress-demo.yaml
# Wait some time till the pod started
kubectl wait --for=condition=available --timeout=600s deployment.apps/echoheaders

# Get the request headers
curl -k https://localhost/echoheaders
`````

