// Orders Microservice Component Test
const request = require('supertest');
const app = require('../server');

describe('Orders Microservice', () => {
  it('should retrieve all orders', async () => {
    const response = await request(app).get('/api/orders');
    expect(response.statusCode).toBe(200);
    expect(Array.isArray(response.body)).toBeTruthy();
  });

  it('should handle order lookup by ID', async () => {
    const testOrderId = 'ORD-000004-MICROSERVICE'; // Example order ID
    const response = await request(app).get(`/api/orders/${testOrderId}`);
    expect(response.statusCode).toBe(200);
    expect(response.body).toHaveProperty('id', testOrderId);
  });
});