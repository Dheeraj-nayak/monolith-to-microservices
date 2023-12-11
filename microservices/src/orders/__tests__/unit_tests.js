const request = require('supertest');
const app = require('../server'); // Adjust the path as necessary

let server;

beforeAll((done) => {
  server = app.listen(8081, done);
});

afterAll((done) => {
  server.close(done);
});


//Fetch All Orders Test
describe('Fetch All Orders', () => {
  it('should return all orders', async () => {
    const res = await request(app).get('/api/orders');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toBeInstanceOf(Array);
  });
});

//Fetch Order by ID Test
describe('Fetch Order by ID', () => {
    it('should return a specific order', async () => {
      const res = await request(app).get('/api/orders/ORD-000004-MICROSERVICE'); // Assuming '1' is a valid ID
      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('id', 'ORD-000004-MICROSERVICE');
    });
  });


//  CORS Handling Test  
describe('CORS Handling', () => {
    it('should enable CORS', async () => {
      const res = await request(app).get('/api/orders');
      expect(res.headers['access-control-allow-origin']).toEqual('*');
    });
  });


  //Mock tests
const ordersData = require('../data/orders.json');

jest.mock('../data/orders.json', () => ({
  orders: [
    { id: 'ORD-000002-MICROSERVICE', cost: 124, date: "7/24/2019" },
    { id: "ORD-000004-MICROSERVICE", cost: 89.83, date: "8/14/2019" },
  ],
}));

describe('Orders Service Fetch Order by ID', () => {
  it('should return a specific mocked order', async () => {
    const res = await request(app).get('/api/orders/ORD-000002-MICROSERVICE');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toEqual({
      id: 'ORD-000002-MICROSERVICE',
      cost: 124,
      date: "7/24/2019"
    });
  });
});