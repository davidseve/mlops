#!/bin/bash

# Name of the project/namespace
NAMESPACE=$1
# Interval between checks (in seconds)
INTERVAL=2
all_running2=false
while true; do
  # Get the list of pods in the namespace
  pods=$(kubectl get pods -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}')

  # Initialize a variable to track if all pods are in Running state
  all_running=true
  

  # Loop through each pod and check its status
  for pod in $pods; do
    # Get the status of the pod
    status=$(kubectl get pod $pod -n $NAMESPACE -o jsonpath='{.status.phase}')
    
    # Check if the status is Running
    if [ "$status" != "Running" ] && [ "$status" != "Completed" ] && [ "$status" != "Succeeded" ]; then
      echo "Pod $pod is not in Running state, current state: $status"
      all_running=false
      all_running2=false
    fi
  done

  # Check the final result
  if $all_running; then
    if $all_running2; then
      echo "All pods are in Running state."
      break
    else
      all_running2=true
      echo "Waiting2 $INTERVAL seconds before rechecking..."
      sleep 10
    fi
  else
    echo "Waiting $INTERVAL seconds before rechecking..."
    sleep $INTERVAL
  fi
done