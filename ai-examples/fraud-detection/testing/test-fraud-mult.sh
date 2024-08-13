
#!/bin/bash

appfile=../gitops/mult/app-ai-fraud-mult.yaml 
appname=ai-fraud-example-mult
namespace=fraud-mult

oc apply -f $appfile

# wait until $appname is available
status=$(oc get application.argoproj.io $appname -n openshift-gitops -o jsonpath='{ .status.resources.sync.status }')
while [[ "${status}" != "Healthy" ]]; do
  sleep 20;
  echo "Wait for app Healthy 20s"
  status=$(oc get application.argoproj.io $appname -n openshift-gitops -o jsonpath='{ .status.health.status }')
done

sleep 30
# wait until $appname is available
status=$(oc get application.argoproj.io $appname -n openshift-gitops -o jsonpath='{ .status.resources.sync.status }')
while [[ "${status}" != "Healthy" ]]; do
  sleep 10;
  echo "Wait for app Healthy 10s"
  status=$(oc get application.argoproj.io $appname -n openshift-gitops -o jsonpath='{ .status.health.status }')
done