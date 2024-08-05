#!/bin/bash
delete_subscription(){
  currentCSV=$(oc get subscription $subscription -n $namespace -o yaml | grep currentCSV | sed 's/  currentCSV: //')
  echo $currentCSV
  oc delete subscription subscription $subscription -n $namespace
  oc delete clusterserviceversion $currentCSV -n $namespace
}

set -x
PATH=${PWD}/bin/:$PATH

#Delete Fraud detection example
cd ../ai-examples/fraud-detection/testing
./delete-fraud.sh
sleep 1

cd ../../../bootstrap
argocd login --core
oc project openshift-gitops

kubectl patch application.argoproj.io argocd-app-of-app -n openshift-gitops --type='json' -p='[{"op": "remove", "path": "/spec/syncPolicy/automated"}]'

#pipelines deletion
namespace=openshift-operators
subscription=openshift-pipelines-operator-rh
currentCSV=$(oc get subscription $subscription -n $namespace -o yaml | grep currentCSV | sed 's/  currentCSV: //')
echo $currentCSV
argocd app delete pipelines --repo-server-name openshift-gitops-repo-server -y
oc delete subscription subscription $subscription -n $namespace
oc delete clusterserviceversion $currentCSV -n $namespace


#serverless deletion
namespace=openshift-serverless
subscription=serverless-operator
currentCSV=$(oc get subscription $subscription -n $namespace -o yaml | grep currentCSV | sed 's/  currentCSV: //')
echo $currentCSV
argocd app delete serverless --repo-server-name openshift-gitops-repo-server -y
oc delete subscription subscription $subscription -n $namespace
oc delete clusterserviceversion $currentCSV -n $namespace
oc delete namespace $namespace

#service-mesh deletion
namespace=openshift-operators
subscription=servicemeshoperator
currentCSV=$(oc get subscription $subscription -n $namespace -o yaml | grep currentCSV | sed 's/  currentCSV: //')
echo $currentCSV
argocd app delete service-mesh --repo-server-name openshift-gitops-repo-server -y
oc delete smmr -n istio-system default
oc delete smcp -n istio-system basic
oc delete validatingwebhookconfiguration/openshift-operators.servicemesh-resources.maistra.io
oc delete mutatingwebhookconfiguration/openshift-operators.servicemesh-resources.maistra.io
oc delete -n openshift-operators daemonset/istio-node
oc delete clusterrole/istio-admin clusterrole/istio-cni clusterrolebinding/istio-cni
oc delete clusterrole istio-view istio-edit
oc delete clusterrole jaegers.jaegertracing.io-v1-admin jaegers.jaegertracing.io-v1-crdview jaegers.jaegertracing.io-v1-edit jaegers.jaegertracing.io-v1-view
oc get crds -o name | grep '.*\.istio\.io' | xargs -r -n 1 oc delete
oc get crds -o name | grep '.*\.maistra\.io' | xargs -r -n 1 oc delete
oc get crds -o name | grep '.*\.kiali\.io' | xargs -r -n 1 oc delete
oc delete crds jaegers.jaegertracing.io
oc delete project istio-system
oc delete subscription subscription $subscription -n $namespace
oc delete clusterserviceversion $currentCSV -n $namespace

#rhods deletion
kubectl patch application.argoproj.io ods -n openshift-gitops --type='json' -p='[{"op": "remove", "path": "/spec/syncPolicy/automated"}]'
oc create configmap delete-self-managed-odh -n redhat-ods-operator
oc label configmap/delete-self-managed-odh api.openshift.com/addon-managed-odh-delete=true -n redhat-ods-operator
PROJECT_NAME=redhat-ods-applications
while oc get project $PROJECT_NAME &> /dev/null; do
  echo "The $PROJECT_NAME project still exists"
  sleep 1
done
echo "The $PROJECT_NAME project no longer exists"
namespace=redhat-ods-operator
subscription=rhods-operator
currentCSV=$(oc get subscription $subscription -n $namespace -o yaml | grep currentCSV | sed 's/  currentCSV: //')
echo $currentCSV
argocd app delete ods --repo-server-name openshift-gitops-repo-server -y
oc delete datasciencecluster default-dsc
oc delete dscinitialization default-dsci
oc delete namespace redhat-ods-operator & /
oc delete namespace redhat-ods-applications & /
oc delete namespace redhat-ods-monitoring & /
oc delete namespace rhods-notebooks
oc delete ns -l opendatahub.io/generated-namespace & /
oc delete ns -l opendatahub.io/dashboard=true
oc delete subscription subscription $subscription -n $namespace
oc delete clusterserviceversion $currentCSV -n $namespace

# delete resources
argocd app delete minio --repo-server-name openshift-gitops-repo-server -y & /
argocd app delete argocd --repo-server-name openshift-gitops-repo-server -y
oc delete -f bootstrap/gitops/appofapp-char.yaml
argocd app delete argocd-app-of-app --repo-server-name openshift-gitops-repo-server -y
sleep 10

#delete  openshift-gitops operator resources
if [[ ${1:-1} = "1" ]]; then
  currentCSV=$(oc get subscription openshift-gitops-operator -n openshift-gitops-operator -o yaml | grep currentCSV | sed 's/  currentCSV: //')
  echo $currentCSV
  oc delete argocd -n openshift-gitops openshift-gitops
  oc delete -f bootstrap/argocd-installation.yaml
  oc delete subscription openshift-gitops-operator -n openshift-gitops-operator
  oc delete clusterserviceversion $currentCSV  -n openshift-gitops-operator
  oc -n openshift-gitops-operator delete installplan --all
  ./bootstrap/ns-pods-running.sh openshift-gitops

  NAMESPACE="openshift-gitops"

  # Interval between checks (in seconds)
  INTERVAL=2

  while true; do
    # Get the list of Application resources in the namespace
    applications=$(kubectl get applications.argoproj.io -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}')
    
    # Initialize a variable to track if there are no Application resources
    no_applications=true

    # Loop through each application and check if it exists
    for app in $applications; do
      echo "Application $app is still present."
      no_applications=false
    done

    # Check the final result
    if $no_applications; then
      echo "No Application resources found in namespace $NAMESPACE."
      break
    else
      echo "Waiting $INTERVAL seconds before rechecking..."
      sleep $INTERVAL
    fi
  done
  oc delete namespace openshift-gitops &
  sleep 10
  NAMESPACE=openshift-gitops
  kubectl proxy &
  kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
  curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize  
  rm temp.json
fi
