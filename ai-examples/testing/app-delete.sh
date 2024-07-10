argocd login --core
oc project openshift-gitops
argocd app delete $1 --repo-server-name openshift-gitops-repo-server -y