# mlops

oc login

cd bootstrap
./bootstrap.sh

TODO if needed
To add Authorino as an authorization provider so that you can enable token authorization for deployed models, you have installed the Red Hat - Authorino Operator. See Installing the Authorino Operator.
https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2-latest/html/serving_models/serving-large-models_serving-large-models?extIdCarryOver=true&sc_cid=701f2000001Css5AAC#installing-the-authorino-operator_serving-large-models
https://github.com/rh-aiservices-bu/rhoai-demo-auth


TODO if needed
Use Existing OpenShift Certificate for Single Stack Serving
https://ai-on-openshift.io/odh-rhoai/single-stack-serving-certificate/
https://github.com/alpha-hack-program/doc-bot/blob/main/bootstrap/hf-creds.sh




## Validate dsc
oc get deployments -n redhat-ods-applications

## Create ai fraud detection example

cd ../ai-examples/fraud-detection/testing
./test-fraud.sh

TODO check s3 second pipeline execution do nothing, but when the pipeline is deleted (not just archived) it is executed again

## Create data science pipelines

## Deleting a workbench from a data science project

## Documentation
DataScienceCluster documentation
https://opendatahub.io/docs/tiered-components/