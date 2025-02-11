# Image Tags
ORDERS_IMAGE_TAG=orders:1.0.0
PRODUCTS_IMAGE_TAG=products:1.0.0
FRONTEND_IMAGE_TAG=frontend:1.0.0


# Install Jest and Supertest for each microservice
cd microservices/src/frontend
npm install --save-dev jest supertest
cd ../orders
npm install --save-dev jest supertest
cd ../products
npm install --save-dev jest supertest

# Build Docker images
cd ../frontend
docker build -t $FRONTEND_IMAGE_TAG .
cd ../orders
docker build -t $ORDERS_IMAGE_TAG .
cd ../products
docker build -t $PRODUCTS_IMAGE_TAG .

# Run Docker containers
docker run -d --rm -p 8080:8080 $FRONTEND_IMAGE_TAG
docker run -d --rm -p 8081:8081 $ORDERS_IMAGE_TAG
docker run -d --rm -p 8082:8082 $PRODUCTS_IMAGE_TAG

# Run tests
cd ../frontend
npm test
cd ../orders
npm test
cd ../products
npm test

echo "Unit, Integration and Component Testing completed."

cd ../../e2e_tests

# Install Selenium WebDriver for e2e tests
echo "Installing Selenium WebDriver..."
npm install selenium-webdriver

# Run e2e tests
echo "Running e2e tests..."

node selenium_test.js

echo "e2e Testing completed."


# Cleanup 
echo "Stopping Docker Containers..."
docker stop $(docker ps -q --filter ancestor=$ORDERS_IMAGE_TAG)
docker stop $(docker ps -q --filter ancestor=$PRODUCTS_IMAGE_TAG)
docker stop $(docker ps -q --filter ancestor=$FRONTEND_IMAGE_TAG)

# Remove Docker Images
echo "Removing Docker Images..."
docker rmi $ORDERS_IMAGE_TAG
docker rmi $PRODUCTS_IMAGE_TAG
docker rmi $FRONTEND_IMAGE_TAG