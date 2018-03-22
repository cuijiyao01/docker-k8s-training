# GKE setup

What you need to do on GKE even if you will use gardener. Things may be different for trial cluster.

You need GCP account and project. Within the GCP dashboard:
- Enable IAM
- create service user: 
  - create service account: gardener-svc-acct
  - select 'furnish private key'
    - check selection: "JSON 
  - select roles: 
    - compute engine -> Compute Admin
    - Service Accounts --> Service Accounts Admin, - Token Creator, - User
  - key is downloaded automatically as JSON. Save into file. 

Now we have to provide secrets etc. so that gardener can manage the VM resources in GCP.

In Gardener:
- create your project and give it a name
- Select Secrets from the menu.
  - Click the question mark (help) and verify that the steps described there have been carried out (see steps above) and the roles are properly assigned (check in IAM of GCP).
    - You may have to go back to GCP IAM and create the kubeoperator user name in the help, and assign the role Compute Admin. 
  - click '+' and paste the whole contest of the JSON file downloaded above into the dialog.
  - give it nice name, e.g. "gardener-secret"

