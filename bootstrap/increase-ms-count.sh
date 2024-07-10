#!/bin/bash


# Parse arguments
NAMESPACE=openshift-machine-api
INCREMENT_COUNT=$1

# Check if increment count is a valid number
if ! [[ "$INCREMENT_COUNT" =~ ^[0-9]+$ ]]; then
  echo "Error: increment count must be a valid number"
  usage
fi

# List MachineSets in the specified namespace
MACHINESET_NAME=$(kubectl get machinesets -n $NAMESPACE -o json | jq -r '.items[0].metadata.name')

# Check if there are any MachineSets in the namespace
if [ -z "$MACHINESET_NAME" ]; then
  echo "Error: No MachineSets found in namespace $NAMESPACE"
  exit 1
fi

echo "Selected MachineSet: $MACHINESET_NAME"

# Get the current replicas count
CURRENT_REPLICAS=$(kubectl get machineset -n $NAMESPACE $MACHINESET_NAME -o json | jq .spec.replicas)

# Calculate the new replicas count
NEW_REPLICAS=$((CURRENT_REPLICAS + INCREMENT_COUNT))

# Patch the MachineSet to update the replicas count
kubectl patch machineset -n $NAMESPACE $MACHINESET_NAME --type='json' -p="[{'op': 'replace', 'path': '/spec/replicas', 'value': $NEW_REPLICAS}]"

# Confirm the update
if [ $? -eq 0 ]; then
  echo "Successfully updated MachineSet $MACHINESET_NAME in namespace $NAMESPACE to $NEW_REPLICAS replicas."
else
  echo "Failed to update MachineSet $MACHINESET_NAME in namespace $NAMESPACE."
fi