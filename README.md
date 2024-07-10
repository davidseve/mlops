# mlops

oc login

./bootstrap/bootstrap.sh

TODO if needed
To add Authorino as an authorization provider so that you can enable token authorization for deployed models, you have installed the Red Hat - Authorino Operator. See Installing the Authorino Operator.
https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2-latest/html/serving_models/serving-large-models_serving-large-models?extIdCarryOver=true&sc_cid=701f2000001Css5AAC#installing-the-authorino-operator_serving-large-models

TODO if needed
Use Existing OpenShift Certificate for Single Stack Serving
https://ai-on-openshift.io/odh-rhoai/single-stack-serving-certificate/
https://github.com/alpha-hack-program/doc-bot/blob/main/bootstrap/hf-creds.sh




## Validate dsc
oc get deployments -n redhat-ods-applications

## Create ai fraud project
oc apply -f ai-examples/gitops/fraud-example/app-ai-fraud.yaml 

TODO
automatizar la subido del modelo fraud
https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2-latest/html/openshift_ai_tutorial_-_fraud_detection_example/creating-a-workbench-and-a-notebook#importing-files-into-jupyter



## Adding a data connection to your data science project


## Creating a project workbench



## Starting a workbench

## Enabling data science pipelines
TODO 
https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2-latest/html/openshift_ai_tutorial_-_fraud_detection_example/setting-up-a-project-and-storage#enabling-data-science-pipelines


## Deleting a workbench from a data science project

## Documentation
DataScienceCluster documentation
https://opendatahub.io/docs/tiered-components/