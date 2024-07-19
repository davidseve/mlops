
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

# TODO validate pipeline is upload, we can check it in S3
cd kfp
oc apply -f kfp-get-pipelines-task.yaml
oc apply -f kfp-get-pipelines-pipeline.yaml
tkn pipeline start pipeline-get-pipelines -n $namespace --showlog

# TODO execute AI pipeline, right now manual from the UI, create a task with a python script that execute the pipeline

# Validate AI pipelines is working
# ../../testing/ns-workflows-running.sh $namespace