#!/bin/bash

url=$1
data=$2


# Expected response body
expected_response=$3


# Retry interval in seconds
retry_interval=5

while true; do
    # Perform the curl command and capture the response and HTTP status code
    response=$(curl -k -X POST -s -w "%{http_code}" -o response_body.txt "$url" -d "$data")
    http_code="${response: -3}"
    body=$(<response_body.txt)
    
    # Check if the HTTP status code is 200 and the response body matches the expected response
    if [[ "$http_code" == "200" && "$body" == "$expected_response" ]]; then
        echo "Success: Received HTTP 200 and expected response."
        break
    else
        echo "Failed: HTTP Code $http_code or unexpected response. Retrying in $retry_interval seconds..."
        sleep "$retry_interval"
    fi
done

# Clean up
rm response_body.txt