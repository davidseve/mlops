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

# install openshift-gitops operator resources
oc get argocd -n openshift-gitops openshift-gitops &>/dev/null
if [[ $? -eq 1 ]]; then
  echo "ArgoCD instance not detected. Installing operator."

  # cleanup existing installplans
  oc -n openshift-gitops-operator delete installplan --all

  # create resources
  oc apply -f bootstrap/argocd-installation.yaml
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
fi

# apply resources
oc apply -f gitops/appofapp-char.yaml
