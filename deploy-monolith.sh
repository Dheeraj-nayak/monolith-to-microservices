#!/bin/bash

# Variables
RESOURCE_GROUP=cicd_microservices
ACR_NAME=cicdmicroservicesacr # Replace with your own unique ACR name.
AKS_NAME=cicdmicroservicesaks # Replace with your desired AKS cluster name.
REGION=eastus
MONOLITH_IMAGE_TAG=monolith:1.0.0

# Create a Resource Group
echo "Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $REGION

# Create an ACR
echo "Creating Azure Container Registry..."
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --location $REGION --admin-enabled true


# Login to ACR
echo "Logging into ACR..."
az acr login --name $ACR_NAME

# Build Monolith Container
echo "Building Monolith Container..."
cd monolith
docker build -t $ACR_NAME.azurecr.io/$MONOLITH_IMAGE_TAG .
cd ..

# Push Monolith Container to ACR
echo "Pushing Monolith Container to ACR..."
docker push $ACR_NAME.azurecr.io/$MONOLITH_IMAGE_TAG

# Get ACR Repository ID
#ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)

# Create AKS Cluster if not exists (check if the cluster exists first)
echo "Checking if AKS Cluster exists..."
if ! az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --output none 2>/dev/null; then
    echo "Creating AKS Cluster..."
    az aks create --resource-group $RESOURCE_GROUP --name $AKS_NAME --node-count 3 --attach-acr ${ACR_NAME} --generate-ssh-keys
else
    echo "AKS Cluster already exists. Skipping creation."
fi


# Get AKS credentials (needed for kubectl commands)
echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

# Deploy Monolith to AKS Cluster
echo "Deploying Monolith to AKS Cluster..."
kubectl create deployment monolith --image=$ACR_NAME.azurecr.io/$MONOLITH_IMAGE_TAG

# Expose Monolith Deployment as a LoadBalancer
echo "Exposing Monolith Deployment as a LoadBalancer..."
kubectl expose deployment monolith --type=LoadBalancer --port=80 --target-port=8080

# Wait for the LoadBalancer to receive an external IP
echo "Waiting for LoadBalancer to receive an external IP..."
while [[ $(kubectl get svc monolith -o 'jsonpath={..status.loadBalancer.ingress[0].ip}') == "" ]]; do 
    echo "Waiting for end point..."
    kubectl get svc monolith
    sleep 10
done

# Output the LoadBalancer IP
echo "Deployment completed successfully!"
echo "Run 'kubectl get service monolith' to find the IP address for the monolith service."
kubectl get service monolith --output jsonpath='{..status.loadBalancer.ingress[0].ip}'






