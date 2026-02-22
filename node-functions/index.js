const { startServer } = require("../server/server");
const { UptimeKumaServer } = require("../server/uptime-kuma-server");

let serverInstance;

module.exports = async (req, res) => {
    if (!serverInstance) {
        // EdgeOne Pages Serverless Environment Configuration
        // Use /tmp for data directory as other paths are likely read-only
        const fs = require('fs');
        const path = require('path');
        const dataDir = '/tmp/data';
        
        if (!fs.existsSync(dataDir)){
            fs.mkdirSync(dataDir, { recursive: true });
        }
        
        process.env.DATA_DIR = dataDir;
        process.env.UPTIME_KUMA_SERVERLESS = "true";
        process.env.UPTIME_KUMA_DB_TYPE = "sqlite";
        
        console.log(`[EdgeOne] Starting Uptime Kuma Serverless... Data Dir: ${dataDir}`);
        
        await startServer(false);
        serverInstance = UptimeKumaServer.getInstance();
    }

    if (req.url.startsWith("/socket.io/")) {
        console.log(`[Socket.io] Handling request: ${req.method} ${req.url}`);
        serverInstance.io.engine.handleRequest(req, res);
        return;
    }

    try {
        serverInstance.app(req, res);
    } catch (error) {
        console.error("[EdgeOne] Request Handler Error:", error);
        res.statusCode = 500;
        res.end("Internal Server Error");
    }
};
