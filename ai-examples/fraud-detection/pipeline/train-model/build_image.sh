#!/bin/bash -e
image_name=quay.io/dseveria/train-model
image_tag=latest
full_image_name=${image_name}:${image_tag}

cp ../../data/card_transdata.csv card_transdata.csv
cd "$(dirname "$0")" 
podman build -t "${full_image_name}" .
rm card_transdata.csv
podman push "$full_image_name"
