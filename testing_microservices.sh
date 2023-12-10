# Install Jest and Supertest for each microservice
cd microservices/src/frontend
npm install --save-dev jest supertest
cd ../orders
npm install --save-dev jest supertest
cd ../products
npm install --save-dev jest supertest

# Build Docker images
cd ../frontend
docker build -t frontend:1.0.0 .
cd ../orders
docker build -t orders:1.0.0 .
cd ../products
docker build -t products:1.0.0 .

# Run Docker containers
docker run -d --rm -p 8080:8080 frontend:1.0.0
docker run -d --rm -p 8081:8081 orders:1.0.0
docker run -d --rm -p 8082:8082 products:1.0.0

# Run tests
cd ../frontend
npm test
cd ../orders
npm test
cd ../products
npm test

echo "Testing completed."