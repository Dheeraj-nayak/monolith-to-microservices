// Products Microservice Component Test
const request = require('supertest');
const app = require('../server');

describe('Products Microservice', () => {
  it('should retrieve product data correctly', async () => {
    const response = await request(app).get('/api/products');
    expect(response.statusCode).toBe(200);
    expect(Array.isArray(response.body)).toBeTruthy();
    expect(response.body.length).toBeGreaterThan(0);
  });

  it('should handle product lookup by ID', async () => {
    const testProductId = '1YMWWN1N4O'; // Example product ID
    const response = await request(app).get(`/api/products/${testProductId}`);
    expect(response.statusCode).toBe(200);
    expect(response.body).toHaveProperty('id', testProductId);
  });
});
