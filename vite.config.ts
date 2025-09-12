import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

const targetServer = process.env.VITE_API_TARGET || 'https://www.mf8ezm.com';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173, // 开发服务器的端口
    proxy: {
      '/vite': {
        target: targetServer, // 目标服务器地址
        changeOrigin: true, // 修改请求的来源
        rewrite: (path) => path.replace(/^\/vite/, ''), // 重写路径
        configure: (proxy) => {
          proxy.on('proxyReq', (proxyReq) => {
            console.log(`[Proxy Request] ${proxyReq.method} ${proxyReq.path}`);
            // Set custom headers for the proxy request
            proxyReq.setHeader('x-api-client', 'h5');
            proxyReq.setHeader('x-api-site', '4002');
            proxyReq.setHeader('x-api-version', '1.0.0');
            proxyReq.setHeader('x-api-type', 'h5');
          });

          proxy.on('proxyRes', (proxyRes, req) => {
            console.log(`[Proxy Response] ${req.method} ${req.url} - ${proxyRes.statusCode}`);
            // Ensure CORS headers are properly set by the proxy
            delete proxyRes.headers['access-control-allow-origin'];
            proxyRes.headers['access-control-allow-origin'] = '*';
          });

          proxy.on('error', (err, req, res) => {
            console.error(`[Proxy Error] ${err.message}`);
            const response = res as import('http').ServerResponse;
            response.writeHead(500, { 'Content-Type': 'text/plain' });
            response.end('Proxy error occurred.');
          });
        },
      },
    },
  },
  build: {
    outDir: 'dist', // Output directory for the build
  },
});
