const request = require('supertest');
const app = require('../server'); // Adjust the path as necessary
let server;

beforeAll((done) => {
  server = app.listen(8082, done);
});

afterAll((done) => {
  server.close(done);
});

describe('Fetch All Products', () => {
  it('should return all products', async () => {
    const res = await request(app).get('/api/products');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toBeInstanceOf(Array);
  });
});


describe('Fetch Product by ID', () => {
    it('should return a specific product', async () => {
      const res = await request(app).get('/api/products/1YMWWN1N4O'); // Assuming '1' is a valid ID
      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('id', '1YMWWN1N4O');
    });
  });

  
 describe('CORS Handling', () => {
    it('should enable CORS', async () => {
      const res = await request(app).get('/api/products');
      expect(res.headers['access-control-allow-origin']).toEqual('*');
    });
  });
  