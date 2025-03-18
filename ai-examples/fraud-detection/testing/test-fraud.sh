
#!/bin/bash

testAPI(){
    if [ "$#" -gt 0 ]; then
        # The URL for the curl command
        url="https://fraudinference-fraud.apps.$1/v2/models/fraudinference/versions/1/infer" 
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


        # Expected response body
        expected_response='{"name":"fraudinference","versions":["1"],"platform":"OpenVINO","inputs":[{"name":"dense_input","datatype":"FP32","shape":[-1,5]}],"outputs":[{"name":"dense_3","datatype":"FP32","shape":[-1,1]}]}'

        # Retry interval in seconds
        retry_interval=5

        while true; do
            # Perform the curl command and capture the response and HTTP status code
            response=$(curl -k -s -w "%{http_code}" -o response_body.txt -X POST "$url" -H "Content-Type: application/json" -d "$data" )
            http_code="${response: -3}"
            body=$(<response_body.txt)
            
            # Check if the HTTP status code is 200 and the response body matches the expected response
            if [[ "$http_code" == "200" ]]; then
                echo "Success: Received HTTP 200 and expected response."
                echo $expected_response
                break
            else
                echo "Failed: HTTP Code $http_code or unexpected response. Retrying in $retry_interval seconds..."
                sleep "$retry_interval"
            fi
            echo $body
        done

        # Clean up
        rm response_body.txt
    fi
}

appfile=ai-examples/fraud-detection/gitops/app-ai-fraud.yaml 
appname=ai-fraud-example

rm -rf /tmp/$appname
mkdir /tmp/$appname
cd /tmp/$appname

git clone https://github.com/davidseve/mlops.git
cd mlops

if [ ${2:-no} != "no" ]
then
    git fetch
    git switch $2
fi
git checkout -b $appname
git push origin $appname

oc apply -f $appfile

# wait until $appname is available
status=$(oc get application.argoproj.io $appname -n openshift-gitops -o jsonpath='{ .status.resources.sync.status }')
while [[ "${status}" != "Healthy" ]]; do
  sleep 20;
  echo "Wait for app Healthy 20s"
  status=$(oc get application.argoproj.io $appname -n openshift-gitops -o jsonpath='{ .status.health.status }')
done

sleep 30
# wait until $appname is available
status=$(oc get application.argoproj.io $appname -n openshift-gitops -o jsonpath='{ .status.resources.sync.status }')
while [[ "${status}" != "Healthy" ]]; do
  sleep 10;
  echo "Wait for app Healthy 10s"
  status=$(oc get application.argoproj.io $appname -n openshift-gitops -o jsonpath='{ .status.health.status }')
done

testAPI $1

# Define variables
NAMESPACE="fraud"
PIPELINE_RUN_NAME="pipeline-run-pipeline-one"
MODEL_VERSION="2"

tkn pipeline start $PIPELINE_RUN_NAME --param MODEL_VERSION=$MODEL_VERSION --param CARDTRANSDATA=https://raw.githubusercontent.com/davidseve/mlops/main/ai-examples/fraud-detection/data/card_transdata.csv-n $NAMESPACE --showlog

sed -i 's/version: 1/version: 2/' ai-examples/fraud-detection/gitops/values-fraud.yaml

git add ai-examples/fraud-detection/gitops/values-fraud.yaml
git commit -m "Change model version to v2"
git push origin $appname

argocd sync app $appname

sleep 1

testAPI $1

