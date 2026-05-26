require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');

const logger = require('./utils/logger');
const { errorHandler, notFound } = require('./middlewares/errorHandler');
const routes = require('./routes');

const app = express();
const PORT = process.env.PORT || 3001;

// Security & parsing middleware
// app.use(helmet());
app.use(compression());
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps or curl)
    if (!origin) return callback(null, true);
    
    const isLocalhost = /^http:\/\/localhost(:\d+)?$/.test(origin);
    const isAllowed = process.env.FRONTEND_URL && (origin === process.env.FRONTEND_URL || origin.startsWith(process.env.FRONTEND_URL));
    
    if (isAllowed || isLocalhost || process.env.NODE_ENV !== 'production') {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined', { stream: { write: (msg) => logger.http(msg.trim()) } }));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), env: process.env.NODE_ENV });
});

// API routes
app.use('/api', routes);

// 404 and error handling
app.use(notFound);
app.use(errorHandler);

const http = require('http');
const { Server } = require('socket.io');
const { initSocket } = require('./services/socketService');

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    credentials: true
  }
});

initSocket(io);

if (!process.env.VERCEL) {
  server.listen(PORT, '0.0.0.0', () => {
    logger.info(`Eternia server running on port ${PORT} (${process.env.NODE_ENV || 'development'})`);
  });
}

module.exports = app;
