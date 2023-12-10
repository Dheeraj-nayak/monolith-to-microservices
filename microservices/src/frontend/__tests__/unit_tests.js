const request = require('supertest');
const app = require('./server'); // Adjust the path as necessary

describe('Static File Serving', () => {
  it('should serve static files', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.headers['content-type']).toContain('text/html');
  });
});


describe('Client-Side Routing', () => {
    it('should handle non-root URLs', async () => {
      const res = await request(app).get('/some-non-existent-route');
      expect(res.statusCode).toEqual(200);
      expect(res.headers['content-type']).toContain('text/html');
    });
  });

  

describe('Server Startup', () => {
    it('should start server on specified port', () => {
      const port = process.env.PORT || 8080;
      expect(app.listen).toHaveBeenCalledWith(port, expect.any(Function));
    });
  });
  