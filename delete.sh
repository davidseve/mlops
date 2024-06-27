#!/bin/bash
delete_subscription(){
  currentCSV=$(oc get subscription $namespace -n $namespace -o yaml | grep currentCSV | sed 's/  currentCSV: //')
  echo $currentCSV
  oc delete subscription subscription $namespace -n $namespace
  oc delete clusterserviceversion $currentCSV -n $namespace
}

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

#serverless deletion
namespace=openshift-serverless
subscription=serverless-operator

#rhods deletion
oc label configmap/delete-self-managed-odh api.openshift.com/addon-managed-odh-delete=true -n redhat-ods-operator
sleep 1
PROJECT_NAME=redhat-ods-applications
while oc get project $PROJECT_NAME &> /dev/null; do
  echo "The $PROJECT_NAME project still exists"
  sleep 1
done
echo "The $PROJECT_NAME project no longer exists"
oc delete namespace redhat-ods-operator
oc delete namespace redhat-ods-applications
oc delete namespace redhat-ods-monitoring
oc delete namespace redhat-ods-operator
oc delete namespace rhods-notebooks

currentCSV=$(oc get subscription rhods-operator -n redhat-ods-operator -o yaml | grep currentCSV | sed 's/  currentCSV: //')
echo $currentCSV
oc delete subscription subscription rhods-operator -n redhat-ods-operator
oc delete clusterserviceversion $currentCSV -n redhat-ods-operator


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
