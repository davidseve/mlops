#!/bin/bash
set -x
PATH=${PWD}/bin/:$PATH

argocd login --core
oc project openshift-gitops
argocd app delete argocd-app-of-app -y

# delete resources
oc delete -f gitops/appofapp-char.yaml

currentCSV=$(oc get subscription openshift-pipelines-operator-rh -n openshift-operators -o yaml | grep currentCSV | sed 's/  currentCSV: //')
echo $currentCSV
oc delete subscription openshift-pipelines-operator-rh -n openshift-operators
oc delete clusterserviceversion $currentCSV -n openshift-operators

#delete  openshift-gitops operator resources
if [[ ${1:-1} = "1" ]]; then
  oc get argocd -n openshift-gitops openshift-gitops &>/dev/null
  if [[ $? = "0" ]]; then
    currentCSV=$(oc get subscription openshift-gitops-operator -n openshift-gitops-operator -o yaml | grep currentCSV | sed 's/  currentCSV: //')
    echo $currentCSV
    oc delete -f bootstrap/argocd-installation.yaml
    oc delete subscription openshift-gitops-operator -n openshift-gitops-operator
    oc delete clusterserviceversion $currentCSV  -n openshift-gitops-operator
  fi
fi
