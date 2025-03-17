FROM quay.io/modh/runtime-images:runtime-cuda-tensorflow-ubi9-python-3.11-20250213   
RUN python3 -m pip install keras
COPY ./train_model.py /pipelines/component/src/train_model.py