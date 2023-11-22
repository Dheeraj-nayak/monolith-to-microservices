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

BASE_PATH=./microservices/src

# Function to Build and Push Image
build_and_push_image() {
    SERVICE_NAME=$1
    IMAGE_TAG=$2
    SERVICE_PATH="$BASE_PATH/$SERVICE_NAME"
    echo "Building Container for $SERVICE_NAME..."
    
    # Navigate to the microservice directory
    cd $SERVICE_PATH
    
    # Build the Docker image
    docker build -t $ACR_NAME.azurecr.io/$IMAGE_TAG .
    
    # Push the Docker image to ACR
    echo "Pushing Container to ACR..."
    docker push $ACR_NAME.azurecr.io/$IMAGE_TAG
    
    # Return to the original script directory
    cd - 
}


# Build and Push Microservices Images
build_and_push_image "orders" $ORDERS_IMAGE_TAG
build_and_push_image "products" $PRODUCTS_IMAGE_TAG
#build_and_push_image "frontend" $FRONTEND_IMAGE_TAG

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
#deploy_and_expose_microservice "frontend" $FRONTEND_IMAGE_TAG 80 8080

# Function to retrieve the LoadBalancer IP for a given service
get_service_external_ip() {
    SERVICE_NAME=$1
    PORT=$2
    while : ; do
        IP=$(kubectl get svc $SERVICE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        if [ ! -z $IP ]; then
            break
        fi
        #echo "Waiting for external IP address for $SERVICE_NAME..."
        sleep 10
    done
    echo "$IP:$PORT"
}

# Retrieve and set the external IP addresses for orders and products
ORDERS_IP=$(get_service_external_ip "orders" 80)
PRODUCTS_IP=$(get_service_external_ip "products" 80)

# Path to the .env file in the react-app directory
ENV_FILE_PATH="$(pwd)/react-app/.env"

# Update the .env file with the new IP addresses
echo "Updating .env file with service IP addresses..."
echo "REACT_APP_ORDERS_URL=http://$ORDERS_IP/api/orders" > $ENV_FILE_PATH
echo "REACT_APP_PRODUCTS_URL=http://$PRODUCTS_IP/api/products" >> $ENV_FILE_PATH

# Navigate to the react-app directory
cd react-app

# Install npm dependencies and rebuild the React app
echo "Building React app with new service IP addresses..."
npm install
npm run build

# Navigate back to the script's base directory
cd ..

# Build and Push the frontend image after updating the .env
echo "Building and pushing the frontend image..."
build_and_push_image "frontend" $FRONTEND_IMAGE_TAG 

# Deploy Frontend microservice
deploy_and_expose_microservice "frontend" $FRONTEND_IMAGE_TAG 80 8080

# Final Status
echo "Deployment completed successfully!"
echo "Run 'kubectl get service frontend' to find the IP addresses for the microservices app."


