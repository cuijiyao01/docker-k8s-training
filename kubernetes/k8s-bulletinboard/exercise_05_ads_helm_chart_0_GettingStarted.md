Exercise 1: Getting Started - Create Helm Chart
====================================================

## Learning Goal
Get familiar with chart structure. 


## Prerequisite

- none

## Step 1: Create default chart

To get things started, create a default chart with helm authoring tools:

```commandline
$ helm create bulletinboard-ads                                                    
Creating bulletinboard-ads
```

The new chart is stored in a directory named `bulletinboard-ads`. Inspect the structure created by Helm.
```
bulletinboard-ads
  Chart.yaml         
  charts/
  templates/ 
  values.yaml         
``` 

What will this default chart do?


## Step 2: Install the chart
```commandline
helm install bulletinboard-ads 
```

## Step 3: Author the information about the chart 

- `Chart.yaml` Add some more fields, like sources or maintainers. See https://github.com/helm/helm/blob/master/docs/charts.md#the-chartyaml-file
- `Values.yaml` Change service port https://github.com/helm/helm/blob/master/docs/charts.md#values-files

Update the Chart

```commandline
helm upgrade <chart-name> bulletinboard-ads 
```