
#!/bin/bash

clusterdomain=$(oc get dns.config/cluster -o jsonpath='{.spec.baseDomain}')

testAPI(){
    if [ "$#" -gt 0 ]; then
        # The URL for the curl command
        url="https://fraudinference-fraud.apps.$clusterdomain/v2/models/fraudinference/versions/1/infer" 

        # Retry interval in seconds
        retry_interval=5

        while true; do
            # Perform the curl command and capture the response and HTTP status code
            response=$(curl -k -s -w "%{http_code}" -o response_body.txt -X POST "$url" -H "Content-Type: application/json" -d "$1" )
            http_code="${response: -3}"
            
            # Check if the HTTP status code is 200 and the response body matches the expected response
            if [[ "$http_code" == "200" ]]; then
                echo "Success: Received HTTP 200 and expected response."
                cat response_body.txt
                break
            else
                echo "Failed: HTTP Code $http_code or unexpected response. Retrying in $retry_interval seconds..."
                cat response_body.txt
                sleep "$retry_interval"
            fi
            
        done

        # Clean up
        rm response_body.txt
    fi
}

appfile=ai-examples/fraud-detection/gitops/app-ai-fraud.yaml 
appname=ai-fraud-example

# Fraud
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
testAPI "$data"

