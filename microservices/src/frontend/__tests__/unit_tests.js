const request = require('supertest');
const app = require('../server'); // Adjust the path as necessary
let server;

beforeAll((done) => {
  server = app.listen(0, done); // Listen on a random available port
});

afterAll((done) => {
  server.close(done);
});

describe('Frontend Service Tests', () => {
  it('should serve the main page', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.headers['content-type']).toContain('text/html');
    expect(res.text).toContain('<div id="root"></div>'); // Check for a specific part of your main page
  });

  it('should handle non-existent routes', async () => {
    const res = await request(app).get('/non-existent-route');
    expect(res.statusCode).toEqual(200);
    expect(res.headers['content-type']).toContain('text/html');
    expect(res.text).toContain('<div id="root"></div>'); // The SPA's entry point should still be served
  });

  it('should serve static assets', async () => {
    // Assuming there's a static image at public/static/img/sample.jpg
    const res = await request(app).get('/static/img/camera-lens.jpg');
    expect(res.statusCode).toEqual(200);
    expect(res.headers['content-type']).toContain('image/jpeg');
  });
});