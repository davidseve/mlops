# Package to bootstrap Data Science projects on Openshift AI
In Openshift AI, a user can create a Data Science Project, which is nothing more than an Openshift project with a label `opendatahub.io/dashboard: 'true'`.
If a Data scienece project is available, the user can create up to `n` different workbenches. A workbench is essentially a container that exposes a GUI and allows the data scientist to work with it. Common environments here are Jupyter Notebook or Visual Studio Code.
With this packet, individual projects can be created and managed automatically via GitOps.

## TL;DR

```console
helm install my-release <URL>
```

## Prerequisites
- Opeshift Version 4.15
- Openshift AI 2.8

## Create a Workbench
The following entry in the values defines a single workbench:

```yaml
  - notebook-one:
    enabled: true
      # name of the workbench
    name: workbench-one
      # image used by the workbench
    image: image-registry.openshift-image-registry.svc:5000/redhat-ods-applications/workbench-one:latest
```
The container requests and limits in a workbench can be defined as follows:
```yaml
  - notebook-one:
    ...
    resources:
      limits:
        gpu: 0 # set to 0 to disable gpu
        cpu: '2'
        memory: 8Gi
      requests:
        cpu: '1'
        memory: 8Gi
```
Persistent storage can be attached to a notebook so that all files can be saved permanently.
```yaml
  - notebook-one:
    ...
    storage:
      # storage name if storage is enabled
      name: storage-name
      # storage size if storage is enabled
      size: 20Gi
```
To create a reference to a data connection, it must be referenced in the notebook. 
A total of up to n dataconnections can be referenced.
But be careful, a dataconnection with the appropriate name must then exist.
```yaml
  - notebook-one:
    ...
    dataconnections:
      - dataconnection-one
      - dataconnection-two
```

## Create a Dataconnection
In terms of safety, this is the most interesting part. The data connections currently contain the credentials in plain text. This means that the data should not be checked into a version control program. One possibility would be to use Sealed Secrets, which was deliberately omitted in this example:
```yaml
  - dataconnection-one:
    # name of the data connection
    name: dataconnection-one
    data:
      AWS_ACCESS_KEY_ID: YmxhaA==
      AWS_DEFAULT_REGION: bm8tcmVnaW9u
      AWS_S3_BUCKET: YnVja2V0
      AWS_S3_ENDPOINT: YmxhaA==
      AWS_SECRET_ACCESS_KEY: YmxhaA==
```

## Model serving




## Running the Pipelines with the Trigger

### Executing the Pipeline upload

```bash
CLUSTER_DOMAIN=$(oc get dns.config/cluster -o jsonpath='{.spec.baseDomain}')
```

```bash
curl -L -X POST "https://el-pipeline-upload-fraud.apps.$CLUSTER_DOMAIN" \
-H 'Content-Type: application/json' \
--data '{
  "commits": [
    {
      "id": "abc123",
      "message": "Example commit message",
      "timestamp": "2025-04-04T12:00:00Z",
      "url": "https://github.com/user/repo/commit/abc123",
      "added": ["file1.txt"],
      "modified": ["ai-examples/fraud-detection/pipeline/file2.txt"],
      "removed": ["file3.txt"]
    }
  ],
  "repository": {
    "id": 123456,
    "name": "example-repo",
    "full_name": "user/example-repo"
  },
  "pusher": {
    "name": "username",
    "email": "user@example.com"
  }
}'
```

### Executing the Pipeline run

```bash
curl -L -X POST "https://el-pipeline-run-fraud.apps.$CLUSTER_DOMAIN" \
-H 'Content-Type: application/json' \
--data '{
  "commits": [
    {
      "id": "abc123",
      "message": "Example commit message",
      "timestamp": "2025-04-04T12:00:00Z",
      "url": "https://github.com/user/repo/commit/abc123",
      "added": ["file1.txt"],
      "modified": ["ai-examples/fraud-detection/data/card_transdata.csv"],
      "removed": ["file3.txt"]
    }
  ],
  "repository": {
    "id": 123456,
    "name": "example-repo",
    "full_name": "user/example-repo"
  },
  "pusher": {
    "name": "username",
    "email": "user@example.com"
  }
}'
```