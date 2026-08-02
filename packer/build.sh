#!/bin/bash
set -euo pipefail

# Usage: ./build.sh <image_version>
# Example: ./build.sh 1.0.0

IMAGE_VERSION="${1:?Usage: ./build.sh <image_version>}"

SUBSCRIPTION_ID="${SUBSCRIPTION_ID:?Set SUBSCRIPTION_ID env var}"
RESOURCE_GROUP_NAME="rg-bytebrain-dev-southindia"
VNET_NAME="vnet-bytebrain-dev-centralindia"
SUBNET_NAME="bytebrain-app"
GALLERY_NAME="bytebrain_gallery"
GALLERY_IMAGE_NAME="bytebrain-app-image"

cd "$(dirname "$0")"

echo "Initializing Packer plugins..."
packer init bytebrain-app.pkr.hcl

echo "Validating template..."
packer validate \
  -var="subscription_id=$SUBSCRIPTION_ID" \
  -var="resource_group_name=$RESOURCE_GROUP_NAME" \
  -var="vnet_name=$VNET_NAME" \
  -var="subnet_name=$SUBNET_NAME" \
  -var="image_version=$IMAGE_VERSION" \
  -var="gallery_name=$GALLERY_NAME" \
  -var="gallery_image_name=$GALLERY_IMAGE_NAME" \
  bytebrain-app.pkr.hcl

echo "Building image version $IMAGE_VERSION..."
packer build \
  -var="subscription_id=$SUBSCRIPTION_ID" \
  -var="resource_group_name=$RESOURCE_GROUP_NAME" \
  -var="vnet_name=$VNET_NAME" \
  -var="subnet_name=$SUBNET_NAME" \
  -var="image_version=$IMAGE_VERSION" \
  -var="gallery_name=$GALLERY_NAME" \
  -var="gallery_image_name=$GALLERY_IMAGE_NAME" \
  bytebrain-app.pkr.hcl

echo "Image version $IMAGE_VERSION built and published successfully."