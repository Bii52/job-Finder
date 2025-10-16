import 'dotenv/config';
import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import http from 'http';
import { Server } from 'socket.io';

if (!process.env.JWT_SECRET) {
  console.error('FATAL ERROR: JWT_SECRET is not defined. Please set this environment variable.');
  process.exit(1);
}

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
  }
});

const PORT = process.env.PORT || 3000;
app.use(cors()); 
app.use(express.json());
app.use('/uploads', express.static('uploads'));

import userRoutes from './src/routes/user.route.js';
app.use('/api/users', userRoutes);
import jobRoutes from './src/routes/job.route.js';
app.use('/api/jobs', jobRoutes);
import chatRoutes from './src/routes/chat.route.js';
app.use('/api/chat', chatRoutes);
import reviewRoutes from './src/routes/review.route.js';
app.use('/api/reviews', reviewRoutes);

// Socket.io connection
io.on('connection', (socket) => {
  console.log('A user connected:', socket.id);

  // Join a conversation room
  socket.on('joinRoom', (conversationId) => {
    socket.join(conversationId);
    console.log(`User ${socket.id} joined room ${conversationId}`);
  });

  // Listen for new messages
  socket.on('sendMessage', (data) => {
    // Broadcast the message to the specific room
    io.to(data.conversationId).emit('receiveMessage', data.message);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
    .then(() => {
        console.log('Connected to MongoDB');
        // Start the server after successful connection
        server.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error('Database connection error:', err);
    });
