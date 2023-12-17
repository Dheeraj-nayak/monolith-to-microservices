const request = require('supertest');
const app = require('../server'); 
const ordersData = require('../data/orders.json');

jest.mock('../data/orders.json', () => ({
  orders: [
    { id: 'ORD-000002-MICROSERVICE', cost: 124, date: "7/24/2019" },
    { id: "ORD-000004-MICROSERVICE", cost: 89.83, date: "8/14/2019" },
  ],
}));

describe('Orders Service Integration Tests', () => {
  it('should return mocked orders', async () => {
    const res = await request(app).get('/api/orders');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toEqual(ordersData.orders);
  });

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
