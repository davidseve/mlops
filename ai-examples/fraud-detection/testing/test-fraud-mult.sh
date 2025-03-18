
#!/bin/bash

appfile=../gitops/mult/app-ai-fraud-mult.yaml 
appname=ai-fraud-example-mult

rm -rf /tmp/$appfile
mkdir /tmp/$appfile
cd /tmp/$appfile

git clone https://github.com/davidseve/mlops.git
cd mlops

if [ ${1:-no} != "no" ]
then
    git fetch
    git switch $1
fi
git checkout -b $appfile
git push origin $appfile

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
 
# The URL for the curl command
url="https://fraud-multinference-fraud-mult.apps.dseveria.sandbox664.opentlc.com/v2/models/fraud-multinference/versions/1/infer" 
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
expected_response='{"name":"fraud-multinference","versions":["1"],"platform":"OpenVINO","inputs":[{"name":"dense_input","datatype":"FP32","shape":[-1,5]}],"outputs":[{"name":"dense_3","datatype":"FP32","shape":[-1,1]}]}'

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
done

curl -k https://fraud-multinference-predictor-fraud-mult.apps.dseveria.sandbox664.opentlc.com/v2/models/fraud-multinference


# Clean up
rm response_body.txt


