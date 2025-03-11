 cat <<EOF | oc create -f -
              apiVersion: tekton.dev/v1
              kind: PipelineRun
              metadata:
                  generateName: pipeline-run-pipeline-one
                  namespace: fraud
                  labels:
                    initial-pipeline-run: "true"
                    pipeline-run: "pipeline-run-pipeline-one"
              spec:
                  pipelineRef:
                    name: pipeline-run-pipeline-one
          EOF