const request = require('supertest');
const app = require('../server'); // Adjust the path as necessary

describe('Fetch All Products', () => {
  it('should return all products', async () => {
    const res = await request(app).get('/api/products');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toBeInstanceOf(Array);
  });
});


describe('Fetch Product by ID', () => {
    it('should return a specific product', async () => {
      const res = await request(app).get('/api/products/1'); // Assuming '1' is a valid ID
      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('id', '1');
    });
  });

  
 describe('CORS Handling', () => {
    it('should enable CORS', async () => {
      const res = await request(app).get('/api/products');
      expect(res.headers['access-control-allow-origin']).toEqual('*');
    });
  });
  