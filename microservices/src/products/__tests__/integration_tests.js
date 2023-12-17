const request = require('supertest');
const app = require('../server'); // Adjust the path to your products server file
const productsData = require('../data/products.json');

// Mocking the products data
jest.mock('../data/products.json', () => ({
    products: [
      { id: "OLJCESPC7Z", name: "MS - Vintage Typewriter", cost: 67.99 },
      { id: "66VCHSJNUP", name: "MS - Vintage Camera Lens", cost: 12.49 },
    ],
  }));

describe('Products Service Integration Tests', () => {
  it('should return mocked products', async () => {
    const res = await request(app).get('/api/products');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toEqual(productsData.products);
  });

  it('should return a specific mocked product', async () => {
    const productId = 'OLJCESPC7Z';
    const res = await request(app).get(`/api/products/${productId}`);
    expect(res.statusCode).toEqual(200);
    expect(res.body).toEqual({
         id: "OLJCESPC7Z", name: "MS - Vintage Typewriter", cost: 67.99
    });
  });
});
