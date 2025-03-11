import os
import re
import sys

import kfp

from kfp import compiler
from kfp import dsl, components
from kfp.dsl import Input, Output, Dataset, Model, Metrics, InputPath, OutputPath

from kfp import kubernetes

from kubernetes import client, config

@dsl.component(base_image="quay.io/modh/runtime-images:runtime-cuda-tensorflow-ubi9-python-3.11-20250213")
def get_data(data_output_path: OutputPath()):
    import urllib.request
    print("starting download...")
    url = "https://raw.githubusercontent.com/davidseve/mlops/main/ai-examples/fraud-detection/data/card_transdata.csv"
    urllib.request.urlretrieve(url, data_output_path)
    print("done")


@dsl.component(
    base_image="quay.io/modh/runtime-images:runtime-cuda-tensorflow-ubi9-python-3.11-20250213",
    packages_to_install=["boto3", "botocore"]
)
def upload_model(input_model_path: InputPath()):
    import os
    import boto3
    import botocore

    aws_access_key_id = os.environ.get('AWS_ACCESS_KEY_ID')
    aws_secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
    endpoint_url = "http://minio.minio.svc.cluster.local:9000" #TODO
    region_name = os.environ.get('AWS_DEFAULT_REGION')
    bucket_name = os.environ.get('AWS_S3_BUCKET')

    s3_key = os.environ.get("S3_KEY")

    print(f"Uploading {input_model_path} to {s3_key} in {bucket_name} bucket in {endpoint_url} endpoint")

    session = boto3.session.Session(aws_access_key_id=aws_access_key_id,
                                    aws_secret_access_key=aws_secret_access_key)

    s3_resource = session.resource(
        's3',
        config=botocore.client.Config(signature_version='s3v4'),
        endpoint_url=endpoint_url,
        region_name=region_name)

    bucket = s3_resource.Bucket(bucket_name)

    print(f"Uploading {s3_key}")
    bucket.upload_file(input_model_path, s3_key)


@dsl.pipeline(name=os.path.basename(__file__).replace('.py', ''))
def pipeline(s3_key: str ,
               secret_name: str):
    get_data_task = get_data()
    csv_file = get_data_task.outputs["data_output_path"]
    # csv_file = get_data_task.output


    train_model = components.load_component_from_url(
        'https://raw.githubusercontent.com/davidseve/mlops/main/ai-examples/fraud-detection/pipeline/train-model/component.yaml'
    )

    train_model_task = train_model(data_input_path=csv_file)
    onnx_file = train_model_task.outputs["model_output_path"]

    upload_model_task = upload_model(input_model_path=onnx_file)

    upload_model_task.set_env_variable(name="S3_KEY", value=s3_key) #TODO manage here Model versioning

    kubernetes.use_secret_as_env(
        task=upload_model_task,
        secret_name='dataconnection-one', #TODO this should be a parameter from the pipeline
        secret_key_to_env={
            'AWS_ACCESS_KEY_ID': 'AWS_ACCESS_KEY_ID',
            'AWS_SECRET_ACCESS_KEY': 'AWS_SECRET_ACCESS_KEY',
            'AWS_DEFAULT_REGION': 'AWS_DEFAULT_REGION',
            'AWS_S3_BUCKET': 'AWS_S3_BUCKET',
            'AWS_S3_ENDPOINT': 'AWS_S3_ENDPOINT',
        })

def get_pipeline_by_name(client: kfp.Client, pipeline_name: str):
    import json

    # Define filter predicates
    filter_spec = json.dumps({
        "predicates": [{
            "key": "display_name",
            "operation": "EQUALS",
            "stringValue": pipeline_name,
        }]
    })

    # List pipelines with the specified filter
    pipelines = client.list_pipelines(filter=filter_spec)

    if not pipelines.pipelines:
        return None
    for pipeline in pipelines.pipelines:
        if pipeline.display_name == pipeline_name:
            return pipeline

    return None

# Get the service account token or return None
def get_token():
    try:
        with open("/var/run/secrets/kubernetes.io/serviceaccount/token", "r") as f:
            return f.read().strip()
    except Exception as e:
        print(f"Error: {e}")
        return None

# Get the route host for the specified route name in the specified namespace
def get_route_host(route_name: str):
    # Load in-cluster Kubernetes configuration but if it fails, load local configuration
    try:
        config.load_incluster_config()
    except config.config_exception.ConfigException:
        config.load_kube_config()

    # Get the current namespace
    with open("/var/run/secrets/kubernetes.io/serviceaccount/namespace", "r") as f:
        namespace = f.read().strip()

    # Create Kubernetes API client
    api_instance = client.CustomObjectsApi()

    try:
        # Retrieve the route object
        route = api_instance.get_namespaced_custom_object(
            group="route.openshift.io",
            version="v1",
            namespace=namespace,
            plural="routes",
            name=route_name
        )

        # Extract spec.host field
        route_host = route['spec']['host']
        return route_host
    
    except Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == '__main__':
    import time

    pipeline_package_path = __file__.replace('.py', '.yaml')

    compiler.Compiler().compile(
        pipeline_func=pipeline,
        package_path=pipeline_package_path
    )

    # Take token and kfp_endpoint as optional command-line arguments
    token = sys.argv[1] if len(sys.argv) > 1 else None
    kfp_endpoint = sys.argv[2] if len(sys.argv) > 2 else None

    if not token:
        print("Token endpoint not provided finding it automatically.")
        token = get_token()

    if not kfp_endpoint:
        print("KFP endpoint not provided finding it automatically.")
        kfp_endpoint = get_route_host(route_name="ds-pipeline-dspa")

    # Pipeline name
    pipeline_name = os.path.basename(__file__).replace('.py', '')

    # If both kfp_endpoint and token are provided, upload the pipeline
    if kfp_endpoint and token:
        # If endpoint doesn't have a protocol (http or https), add https
        if not kfp_endpoint.startswith("http"):
            kfp_endpoint = f"https://{kfp_endpoint}"

        client = kfp.Client(host=kfp_endpoint, existing_token=token, ssl_ca_cert="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt",)

        try:
            # Get the pipeline by name
            print(f"Pipeline name: {pipeline_name}")
            existing_pipeline = get_pipeline_by_name(client, pipeline_name)
            if existing_pipeline:
                print(f"Pipeline {existing_pipeline.pipeline_id} already exists. Uploading a new version.")
                # Upload a new version of the pipeline with a version name equal to the pipeline package path plus a timestamp
                pipeline_version_name=f"{pipeline_name}-{int(time.time())}"
                client.upload_pipeline_version(
                    pipeline_package_path=pipeline_package_path,
                    pipeline_id=existing_pipeline.pipeline_id,
                    pipeline_version_name=pipeline_version_name
                )
                print(f"Pipeline version uploaded successfully to {kfp_endpoint}")
            else:
                print(f"Pipeline {pipeline_name} does not exist. Uploading a new pipeline.")
                print(f"Pipeline package path: {pipeline_package_path}")
                # Upload the compiled pipeline
                client.upload_pipeline(
                    pipeline_package_path=pipeline_package_path,
                    pipeline_name=pipeline_name
                )
                print(f"Pipeline uploaded successfully to {kfp_endpoint}")
        except Exception as e:
            print(f"Failed to upload the pipeline: {e}")
    else:
        print("KFP endpoint or token not provided. Skipping pipeline upload.")