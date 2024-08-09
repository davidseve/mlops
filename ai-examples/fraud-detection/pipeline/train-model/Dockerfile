FROM quay.io/modh/runtime-images:runtime-cuda-tensorflow-ubi9-python-3.9-2023b-20240301
RUN python3 -m pip install keras
COPY ./train_model.py /pipelines/component/src/train_model.py