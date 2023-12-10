const request = require('supertest');
const app = require('./server'); // Adjust the path as necessary

describe('Fetch All Orders', () => {
  it('should return all orders', async () => {
    const res = await request(app).get('/api/orders');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toBeInstanceOf(Array);
  });
});


describe('Fetch Order by ID', () => {
    it('should return a specific order', async () => {
      const res = await request(app).get('/api/orders/1'); // Assuming '1' is a valid ID
      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('id', '1');
    });
  });

  
describe('CORS Handling', () => {
    it('should enable CORS', async () => {
      const res = await request(app).get('/api/orders');
      expect(res.headers['access-control-allow-origin']).toEqual('*');
    });
  });
  