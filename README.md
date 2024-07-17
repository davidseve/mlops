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

cd ../ai-examples/fraud-detection
./test-fraud.sh




## Enabling data science pipelines
TODO 
https://github.com/alpha-hack-program/sagemaker-rhoai/tree/main


Trevor Royer
  1 minute ago
Example tekton pipeline here:
https://github.com/redhat-ai-services/ai-accelerator/tree/main/tenants/ai-example/dsp-example-pipeline/base
The kfp pipeline that it is triggering can be found here:
https://github.com/redhat-ai-services/kubeflow-pipelines-examples/blob/main/pipelines/11_iris_training_pipeline.py
The if __name__ == "__main__": section at the bottom is all of the magic sauce to authenticate to the dsp api and line 255 is the piece that triggers the run.

https://rh-aiservices-bu.github.io/fraud-detection/fraud-detection-workshop/running-a-pipeline-generated-from-python-code.html
https://github.com/rh-aiservices-bu/fraud-detection/blob/53da9bc16ee64c39d4eaa620952a25ea157b118f/7_get_data_train_upload.yaml


## Deleting a workbench from a data science project

## Documentation
DataScienceCluster documentation
https://opendatahub.io/docs/tiered-components/