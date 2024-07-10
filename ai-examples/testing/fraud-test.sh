
#!/bin/bash

appfile=ai-examples/gitops/fraud-example/app-ai-fraud.yaml 
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


containerState=$(oc get notebook $workbench -n $namespace -o jsonpath='{ .status.containerState }')

VALID=$(echo $containerState | jq -e '.running' 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "Invalid JSON format or 'running' field not found"
  exit 1
fi

while [ $? -ne 0 ]
do 
    echo "Waiting ${x} times for notebook $workbench -n $namespace" $(( x++ ))
    sleep 2 
    test=$(oc get po -n ${2} | grep ${1})
done

#oc delete application.argoproj.io -n openshift-gitops ai-fraud-example --cascade='foreground'


--logout-url=https://rhods-dashboard-redhat-ods-applications.apps.cluster-87xpx.87xpx.sandbox1137.opentlc.com/projects/fraud?notebookLogout=-workbench-one
--logout-url=https://rhods-dashboard-redhat-ods-applications.apps.cluster-87xpx.87xpx.sandbox1137.opentlc.com/projects/fraud?notebookLogout=workbench-one