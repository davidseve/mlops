# MLOps with Red Hat OpenShift AI following GitOps

This repository is a comprehensive framework for deploying and managing machine learning projects on Red Hat OpenShift AI using a GitOps approach. It provides tools and examples to streamline the deployment of AI/ML workloads, including a standard Helm chart for data science projects and a reference example for deploying a fraud detection model.

## Features

### 1. Red Hat OpenShift AI Installation (GitOps Mode)
- Leverages GitOps principles to automate the installation and management of AI tools on OpenShift.
- Ensures consistency and traceability across environments.

### 2. Standard Helm Chart for Data Science Projects
- A reusable and configurable Helm chart designed for deploying various data science workloads.
- Simplifies deployment and scaling of ML models and supporting infrastructure.

### 3. Fraud Detection Model Example
- Demonstrates a complete workflow for deploying a fraud detection model.
- Implements GitOps practices to manage the lifecycle of the model.
- Includes best practices for CI/CD pipelines.

## Getting Started

### Prerequisites

1. **Red Hat OpenShift**
   - Assume you already have OpenShift 4.17 or later installed.
   - Install the OpenShift CLI (`oc`).

### Installation

#### Step 1: Clone the Repository
```bash
git clone https://github.com/davidseve/mlops.git
cd mlops
```

#### Step 2: Install OpenShift AI 
```bash
cd bootstrap
./bootstrap.sh
```
It could take several minutes

#### Step 3: Validate dsc
```bash
oc get deployments -n redhat-ods-applications
```

#### Step 4: Create AI Fraud Detection Example
```bash
cd ../ai-examples/fraud-detection/testing
./test-fraud.sh
```
It could take several minutes

#### Step 4: Validate Fraud Detection inference
```bash
host=<YOUR_HOST>
url="https://fraudinference-fraud.apps.$host/v2/models/fraudinference/versions/1/infer" 
data='{
        "id" : "42",
        "inputs": [
                    {
                        "name": "dense_input",
                        "shape": [1, 5],
                        "datatype": "FP32",
                        "data": [0.3111400080477545, 1.9459399775518593, 1.0, 0.0, 0.0]
                    }
                ]
        }'
curl -k -X POST "$url" -H "Content-Type: application/json" -d "$data"

```

### Clean up


#### Step 1: Delete AI Fraud Detection Example
```bash
./ai-examples/fraud-detection/testing/delete-fraud.sh
```

#### Step 2: Delete Install OpenShift AI
```bash
cd bootstrap
./delete.sh
```








































= mlops

oc login

cd bootstrap
./bootstrap.sh

TODO if needed
To add Authorino as an authorization provider so that you can enable token authorization for deployed models, you have installed the Red Hat - Authorino Operator. See Installing the Authorino Operator.
https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2-latest/html/serving_models/serving-large-models_serving-large-models?extIdCarryOver=true&sc_cid=701f2000001Css5AAC=installing-the-authorino-operator_serving-large-models
https://github.com/rh-aiservices-bu/rhoai-demo-auth


TODO if needed
Use Existing OpenShift Certificate for Single Stack Serving
https://ai-on-openshift.io/odh-rhoai/single-stack-serving-certificate/
https://github.com/alpha-hack-program/doc-bot/blob/main/bootstrap/hf-creds.sh




== Validate dsc
oc get deployments -n redhat-ods-applications

== Create ai fraud detection example

cd ../ai-examples/fraud-detection/testing
./test-fraud.sh

TODO check s3 second pipeline execution do nothing, but when the pipeline is deleted (not just archived) it is executed again

== Create data science pipelines

== Deleting a workbench from a data science project

== Documentation
DataScienceCluster documentation
https://opendatahub.io/docs/tiered-components/