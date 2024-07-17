
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



../../../bootstrap/ns-pods-running.sh $namespace

# TODO validate pipeline is upload, I do not know which is the object that is created

# TODO execute AI pipeline


 ../../testing/ns-workflows-running.sh $namespace