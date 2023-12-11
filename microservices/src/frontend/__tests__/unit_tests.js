const request = require('supertest');
const app = require('../server'); // Adjust the path as necessary
let server;

beforeAll((done) => {
  server = app.listen(8080, done); 
});

afterAll((done) => {
  server.close(done);
});


// Check for a specific part of your main page
describe('Frontend Service Tests', () => {
  it('should serve the main page', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.headers['content-type']).toContain('text/html');
    expect(res.text).toContain('<div id="root"></div>'); 
  });

  //Client-Side Routing Test
  it('should handle non-existent routes', async () => {
    const res = await request(app).get('/non-existent-route');
    expect(res.statusCode).toEqual(200);
    expect(res.headers['content-type']).toContain('text/html');
    expect(res.text).toContain('<div id="root"></div>'); // The SPA's entry point should still be served
  });


  //Static File Serving Test
  it('should serve static assets', async () => {
    const res = await request(app).get('/static/img/products/camera-lens.jpg');
    expect(res.statusCode).toEqual(200);
    expect(res.headers['content-type']).toContain('image/jpeg');
  });
});