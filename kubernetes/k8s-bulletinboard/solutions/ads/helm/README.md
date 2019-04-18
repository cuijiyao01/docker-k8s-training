# Some remarks on the helm solutions

The Solution of the Ads helmchart is written as a solution after Exercise 5.3 with the connection to the users-chart. The Reference to the users-chart relative to this chart as it is in the solutions. Depending on your situation you may need to adjust some things.

Requirements: **docker registry secret exists to pull the images.**

How to use:

- Go to `.../solutions/ads/helm/`
- Adjust value of `Ads.Ingress.Hostname` in `bulletinboard-ads/value.yaml` or set it to a custom value during install with `--set ...`
- do `helm dependency update bulletinboard-ads`
- do `helm install bulletinboard-ads --set ClusterName=<cluster name> --set App.Ingress.Hostname=bulletinboard--part-<id>`.

One Issue:
No TLS for Ingress in this Solution.
