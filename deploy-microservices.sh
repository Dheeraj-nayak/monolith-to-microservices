#!/bin/bash

# Set Variables
RESOURCE_GROUP=microservicescicd
ACR_NAME=microservicescicdacr
AKS_NAME=microservicescicdaks
REGION=eastus

# Image Tags
ORDERS_IMAGE_TAG=orders:1.0.0
PRODUCTS_IMAGE_TAG=products:1.0.0
FRONTEND_IMAGE_TAG=frontend:1.0.0

# Create Resource Group
echo "Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $REGION

# Create ACR
echo "Creating Azure Container Registry..."
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --location $REGION --admin-enabled true

# Login to ACR
echo "Logging into ACR..."
az acr login --name $ACR_NAME

# Function to Build and Push Image
build_and_push_image() {
    SERVICE_NAME=$1
    IMAGE_TAG=$2
    echo "Building $SERVICE_NAME Container..."
    cd $SERVICE_NAME
    docker build -t $ACR_NAME.azurecr.io/$IMAGE_TAG .
    echo "Pushing $SERVICE_NAME Container to ACR..."
    docker push $ACR_NAME.azurecr.io/$IMAGE_TAG
    cd ..
}

# Build and Push Microservices Images
build_and_push_image "orders" $ORDERS_IMAGE_TAG
build_and_push_image "products" $PRODUCTS_IMAGE_TAG
build_and_push_image "frontend" $FRONTEND_IMAGE_TAG

# Create AKS Cluster if not exists
echo "Checking if AKS Cluster exists..."
if ! az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --output none 2>/dev/null; then
    echo "Creating AKS Cluster..."
    az aks create --resource-group $RESOURCE_GROUP --name $AKS_NAME --node-count 3 --attach-acr $ACR_NAME --generate-ssh-keys
else
    echo "AKS Cluster already exists. Skipping creation."
fi

# Get AKS credentials
echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

# Deploy and Expose Microservices
deploy_and_expose_microservice() {
    SERVICE_NAME=$1
    IMAGE_TAG=$2
    PORT=$3
    TARGET_PORT=$4
    echo "Deploying $SERVICE_NAME to AKS Cluster..."
    kubectl create deployment $SERVICE_NAME --image=$ACR_NAME.azurecr.io/$IMAGE_TAG
    echo "Exposing $SERVICE_NAME Deployment as a LoadBalancer..."
    kubectl expose deployment $SERVICE_NAME --type=LoadBalancer --port=$PORT --target-port=$TARGET_PORT
}

# Deploy Microservices
deploy_and_expose_microservice "orders" $ORDERS_IMAGE_TAG 80 8081
deploy_and_expose_microservice "products" $PRODUCTS_IMAGE_TAG 80 8082
deploy_and_expose_microservice "frontend" $FRONTEND_IMAGE_TAG 80 8080

# Final Status
echo "Deployment completed successfully!"
echo "Run 'kubectl get service' to find the IP addresses for the microservices."
