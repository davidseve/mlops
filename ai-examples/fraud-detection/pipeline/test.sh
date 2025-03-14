#!/bin/sh

echo "Compiling pipeline get_data_train_upload.yaml"

echo "Current directory"
pwd

echo "List files"
ls -lstrh


pip install -r requirements.txt

# Upload the pipeline
export NAMESPACE_NAME="a"
export TOKEN="s"
export PIPELINE_NAME="get_data_train_upload"

echo "NAMESPACE_NAME: $NAMESPACE_NAME PIPELINE_NAME: $PIPELINE_NAME TOKEN: $TOKEN"

python get_data_train_upload.py $TOKEN