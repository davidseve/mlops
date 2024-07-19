
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

../../../bootstrap/ns-pods-running.sh $namespace

sleep 10

oc create -f kfp-upload-pipelinerun.yaml

sleep 10

../../../bootstrap/ns-pods-running.sh $namespace

# TODO validate pipeline is upload, we can check it in S3
host=$(oc get route -n $namespace ds-pipeline-dspa -o jsonpath='{.spec.host}')

# TODO execute AI pipeline, right now manual from the UI

# Validate AI pipelines is working
# ../../testing/ns-workflows-running.sh $namespace