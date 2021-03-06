# Exercise 11: Write your first helm chart

In this exercise, you will be dealing with _Helm_.

After having used a ready-made helm chart from the public chart repository on GitHub, it is now time to author a very basic helm chart consisting of a config map which stores information about your favorite food & drinks.

**Note:** This exercise does not build on any of the previous exercises.

## Documentation
The usage of helm and the go functions might not be intuitive. There take a look at these links, they explain the most relevant:

* [overview of helm docs](https://helm.sh/docs/)
* [getting started with chart development](https://helm.sh/docs/intro/quickstart/)
* [how values files work in helm](https://helm.sh/docs/chart_template_guide/values_files/)
* [functions and pipelines](https://helm.sh/docs/chart_template_guide/functions_and_pipelines/)

## Useful commands & flags
* `--dry-run`: simulate your action (like installation or upgrade)
* `--debug`: print out the actual yaml files including the substituted values. Best used with `--dry-run` to test new functionality in your chart.
* `helm lint`: check your chart for yaml errors and correctness

## Draft the chart
### Chart initialization
Though you can create the directory structure as well as all the files manually, helm offers a `create` command.

`helm create <chart-name>` will bootstrap a chart structure with some first demo content for you. Unfortunately, most of the content is not relevant to you right now. But it can be a good source of inspiration.

### Remove superfluous templates
Get rid of the templates which have been generated by `helm create`.
**Hint:** these templates are actually valid & working. In case you need some inspiration, you may take a look into them as well prior to removal.

### Create the config map
Go to the `templates` folder and create new file, which will contain the yaml & code. Write a simple config map with a the following data structure:

```yaml
data:
    drink: < your favorite drink >
    food: < your favorite food >
```

### Adapt values.yaml
Since everyones preferences for food and drinks differ, let's make them configurable. Firstly, delete the old `values.yaml` file - it refers to the generated templates and is not need for this exercise.

Instead create a new `values.yaml` file, which allows you to set values for `drink` and `food` in a `favorites` section. Check the documentation links above, if you are unsure, how to structure and indent the `values.yaml` content.

### Reference values in the template
Next, make use of the values you just defined and include them into data section of your config map.

To mark something as a variable or evaluate a function / pipeline, surround the statement with  `{{ }}`. To refer to a something from the `values.yaml`, start with `.Values` - it points to an object that contains all the data in your `values.yaml` file. Append `.<section>.<parameter>` to navigate through your values.

The values for food and drink will be strings. To make sure, they are treated correctly, you should hand the values over to the `quote` function by using a pipeline `|`. Check the "function and pipeline" link mentioned above for help.

You can use the `helm lint` command to have your code checked in a very basic way.

### Adapt the config map metadata
Now that the data is configurable, let's move on to `metadata`. Most of the times you want to include the release name the labels and name of your resources.
Luckily there are some built-in variables, like the `.Release` object with its `.Name` value. Change the specific name of your config map to include the release name in addition.

**Optional:** If you're up for a challenge, try to set some labels as well. Check the [built-in](https://helm.sh/docs/chart_template_guide/builtin_objects/) objects for suitable values.

### Adapt NOTES.txt
Helm prints out some friendly words and an idea what to do next after a chart was deployed. These information is stored in the `NOTES.txt` file. Adapt the content to something meaningful (e.g. how to get the configmap or some of its content).

## Test & install
One last time, run the `helm lint` command and test your chart with a `--debug` & `--dry-run` installation.
If everything looks as expected, finally install your chart. Try to run the commands you put into the `NOTES.txt`.

Don't forget to query information about your release with `helm list`.

## Extend the chart to create a pod that uses the config map

Go to the `templates` folder and create a file `pod.yaml`. Create a pod that runs a busybox and mounts the config map as a volume. Set the restart policy to `Never`. The pod, once it runs should print the contents of all files of the mounted config map and exit. 

You could simply write a static pod specification but with helm, we can make this a lot more configurable. So using the `values.yaml` file, make the following properties of the pod adjustable:
- image repository
- image tag
- mount point directory to where the config map gets mounted

In order to have pod print out the contents of the config map, use the following snippet in the containers section of the pod specification. To check if the pod really did use the configmap correctly do `kubectl logs <pod of chart>` after the installation and see if it printed the correct food/drinks. The `.Values.pod.mount` is the mount point directory of the config map, so make sure that it gets mounted to the same place.

```yaml
command: [ "/bin/sh", "-c", "for i in $(ls -1 {{ .Values.pod.mount }}/*); do echo -e \"\\nContent of $i: \"; cat $i; done; echo -e \n\n" ]
```

Use `helm lint` to check if your templates and values are syntactically correct. If everything worked so far, you can either do another installation of this chart with `helm install` or you can try to do an...

## Upgrade
The last step in this exercise is to perform various updates on your release.
Use the `helm upgrade` command to bring your release to a new version. As part of an upgrade you can change the structure of the chart (**be very careful with this**) or simply change the values the chart is working with.

Try to run an upgrade and change `food` or `drink` with a `--set` command line parameter to a new value.  
Maybe an upgrade does not restart the job so delete the job-pod before you do an upgrade with `kubectl delete pod <name of the pod completed>`.

By default, the charts `values.yaml` file will be used. But of course you can overwrite it completely or by specifying single values in a separate file. Create a file with custom values and use the `-f` flag to pass it on while upgrading.
