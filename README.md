# mlops

oc login

./bootstrap.sh

## Validate dsc
oc get deployments -n redhat-ods-applications

## Create ai project
https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2.7/html-single/working_on_data_science_projects/index#creating-a-data-science-project_nb-server
kind: Project                             1
apiVersion: project.openshift.io/v1
metadata:
  name: my-ai-project                     2
  labels:
    kubernetes.io/metadata.name: my-ai-project
    modelmesh-enabled: 'true'
    opendatahub.io/dashboard: 'true' 

## Adding a data connection to your data science project


## Creating a project workbench



## Starting a workbench


## Deleting a workbench from a data science project

## Documentation
DataScienceCluster documentation
https://opendatahub.io/docs/tiered-components/