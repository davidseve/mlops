#!/bin/bash
appname=ai-fraud-example-mult
../../testing/app-delete.sh $appname

while true; do
    # Get the list of Application resources in the namespace
    applications=$(oc get applications.argoproj.io $appname -n openshift-gitops -o jsonpath='{.metadata.name}')

    # Initialize a variable to track if there are no Application resources
    no_applications=true

    # Loop through each application and check if it exists
    for app in $applications; do
        echo "Application $app is still present."
        no_applications=false
    done

    # Check the final result
    if $no_applications; then
        echo "No Application resources found in namespace openshift-gitops."
        break
    else
        echo "Waiting 2 seconds before rechecking..."
        sleep 2
    fi
done

git checkout main
git branch -d $appname
git push origin --delete $appname