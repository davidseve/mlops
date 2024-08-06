
#!/bin/bash

appfile=../gitops/app-ai-fraud.yaml 
appname=ai-fraud-example
workbench=workbench-one
namespace=fraud



# Run pipeline
cd kfp
oc apply -f kfp-run-pipelines-task.yaml
oc apply -f kfp-run-pipelines-pipeline.yaml
tkn pipeline start pipeline-run-pipelines -n $namespace --showlog
