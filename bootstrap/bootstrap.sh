#!/bin/bash

waitpodup(){
  x=1
  test=""
  while [ -z "${test}" ]
  do 
    echo "Waiting ${x} times for pod ${1} in ns ${2}" $(( x++ ))
    sleep 2 
    test=$(oc get po -n ${2} | grep ${1})
  done
}

waitoperatorpod() {
  NS=openshift-gitops-operator
  waitpodup $1 ${NS}
  oc get pods -n ${NS} | grep ${1} | awk '{print "oc wait --for condition=Ready -n '${NS}' pod/" $1 " --timeout 300s"}' | sh
}

set -x
PATH=${PWD}/bin/:$PATH

increase-ms-count.sh 2

# install openshift-gitops operator resources
oc get argocd -n openshift-gitops openshift-gitops &>/dev/null
if [[ $? -eq 1 ]]; then
  echo "ArgoCD instance not detected. Installing operator."

  # cleanup existing installplans
  oc -n openshift-gitops-operator delete installplan --all

  # create resources
  oc apply -f argocd-installation.yaml
  # approve new installplan
  sleep 1m

  installPlan=$(oc -n openshift-gitops-operator get subscriptions.operators.coreos.com -o jsonpath='{.items[0].status.installPlanRef.name}')
  oc -n openshift-gitops-operator patch installplan "${installPlan}" --type=json -p='[{"op":"replace","path": "/spec/approved", "value": true}]'
  waitoperatorpod gitops
  # wait until argocd instance is available
  status=$(oc -n openshift-gitops get argocd openshift-gitops -o jsonpath='{ .status.phase }')
  while [[ "${status}" != "Available" ]]; do
    sleep 5;
    status=$(oc -n openshift-gitops get argocd openshift-gitops -o jsonpath='{ .status.phase }')
  done

  # annotate it to enable SSA
  oc -n openshift-gitops annotate --overwrite argocd/openshift-gitops argocd.argoproj.io/sync-options=ServerSideApply=true

  # oc extract secret/openshift-gitops-cluster -n openshift-gitops --to=-
fi

# apply resources
oc apply -f ./gitops/appofapp-char.yaml
sleep 30

# wait until argocd-app-of-app is available
status=$(oc get application.argoproj.io argocd-app-of-app -n openshift-gitops -o jsonpath='{ .status.health.status }')
while [[ "${status}" != "Healthy" ]]; do
  sleep 5;
  status=$(oc get application.argoproj.io argocd-app-of-app -n openshift-gitops -o jsonpath='{ .status.health.status }')
done

sleep 1 # for redhat-ods-applications
# wait until redhat-ods-applications are running
./ns-pods-running.sh redhat-ods-applications
sleep 30
./ns-pods-running.sh redhat-ods-applications
sleep 30
./ns-pods-running.sh redhat-ods-applications
echo "ArgoCD route:"
printf "https://$(oc get route -n openshift-gitops openshift-gitops-server -o jsonpath='{.spec.host}')\n\n"

echo "Admin ArgoCD password:"
oc extract secret/openshift-gitops-cluster -n openshift-gitops --to=-

echo "RHAI dashboard:"
printf "https://$(oc get route -n redhat-ods-applications rhods-dashboard -o jsonpath='{.spec.host}')\n\n"

#Execute Fraud detection example
# sleep 1
# cd ../ai-examples/fraud-detection/testing
# ./test-fraud.sh