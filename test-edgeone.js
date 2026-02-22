process.env.UPTIME_KUMA_SERVERLESS = '1';
process.env.UPTIME_KUMA_DB_TYPE = 'sqlite';
const handler = require('./node-functions/index.js');
const http = require('http');
const { UptimeKumaServer } = require("./server/uptime-kuma-server");

const server = http.createServer(handler);

server.on('upgrade', (req, socket, head) => {
    console.log(`[Socket.io] Handling upgrade: ${req.url}`);
    const io = UptimeKumaServer.getInstance().io;
    if (io) {
        io.engine.handleUpgrade(req, socket, head);
    } else {
        socket.destroy();
    }
});

server.listen(3002, () => {
    console.log('Test server listening on port 3002');
});
