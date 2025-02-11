const request = require('supertest');
const app = require('../server'); // Adjust the path as necessary
let server;

beforeAll((done) => {
  server = app.listen(8082, done);
});

afterAll((done) => {
  server.close(done);
});

//Fetch All Products Test
describe('Fetch All Products', () => {
  it('should return all products', async () => {
    const res = await request(app).get('/api/products');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toBeInstanceOf(Array);
  });
});

//Fetch Product by ID Test
describe('Fetch Product by ID', () => {
    it('should return a specific product', async () => {
      const res = await request(app).get('/api/products/1YMWWN1N4O'); // Assuming '1' is a valid ID
      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('id', '1YMWWN1N4O');
    });
  });

//  CORS Handling Test
 describe('CORS Handling', () => {
    it('should enable CORS', async () => {
      const res = await request(app).get('/api/products');
      expect(res.headers['access-control-allow-origin']).toEqual('*');
    });
  });


//Mock tests
const ordersData = require('../data/products.json');

  jest.mock('../data/products.json', () => ({
    products: [
      { id: "OLJCESPC7Z", name: "MS - Vintage Typewriter", cost: 67.99 },
      { id: "66VCHSJNUP", name: "MS - Vintage Camera Lens", cost: 12.49 },
    ],
  }));
  
  describe('Products Service Fetch All Products', () => {
    it('should return all mocked products', async () => {
      const res = await request(app).get('/api/products');
      expect(res.statusCode).toEqual(200);
      expect(res.body).toEqual([
        { id: "OLJCESPC7Z", name: "MS - Vintage Typewriter", cost: 67.99 },
        { id: "66VCHSJNUP", name: "MS - Vintage Camera Lens", cost: 12.49 },
      ]);
    });
  });
  