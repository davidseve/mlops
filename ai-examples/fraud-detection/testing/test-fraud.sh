
#!/bin/bash

appfile=../gitops/app-ai-fraud.yaml 
appname=ai-fraud-example
workbench=workbench-one
namespace=fraud

oc apply -f $appfile

# wait until $appname is available
status=$(oc get application.argoproj.io $appname -n openshift-gitops -o jsonpath='{ .status.resources.sync.status }')
while [[ "${status}" != "Healthy" ]]; do
  sleep 5;
  status=$(oc get application.argoproj.io $appname -n openshift-gitops -o jsonpath='{ .status.health.status }')
done


sleep 30

tkn pipeline start pipeline-upload-pipeline-one --workspace name=workspace-source,claimName=pipeline-upload-pipeline-one-source-pvc -n $namespace --showlog --use-param-defaults

sleep 10

# Run pipeline
oc apply -f kfp-run-pipelines-task.yaml
oc apply -f kfp-run-pipelines-pipeline.yaml
tkn pipeline start pipeline-run-pipelines -n $namespace --showlog
