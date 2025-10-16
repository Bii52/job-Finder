import Conversation from '../models/conversation.model.js';
import Message from '../models/message.model.js';
import { StatusCodes } from 'http-status-codes';
import ApiError from '../utils/ApiError.js';

const chatController = {
  createConversation: async (req, res, next) => {
    try {
      const { recipientId } = req.body;
      const senderId = req.user.id;

      let conversation = await Conversation.findOne({
        participants: { $all: [senderId, recipientId] },
      }).populate('participants', '-password');

      if (conversation) {
        return res.status(StatusCodes.OK).json(conversation);
      }

      const newConversation = new Conversation({
        participants: [senderId, recipientId],
      });

      const savedConversation = await newConversation.save();
      res.status(StatusCodes.CREATED).json(savedConversation);
    } catch (error) {
      next(error);
    }
  },

  getConversations: async (req, res, next) => {
    try {
      const conversations = await Conversation.find({
        participants: { $in: [req.user.id] },
      }).populate('participants', '-password');
      res.status(StatusCodes.OK).json(conversations);
    } catch (error) {
      next(error);
    }
  },

  getMessages: async (req, res, next) => {
    try {
      const messages = await Message.find({
        conversationId: req.params.conversationId,
      });
      res.status(StatusCodes.OK).json(messages);
    } catch (error) {
      next(error);
    }
  },

  addMessage: async (req, res, next) => {
    try {
      const { conversationId, text } = req.body;
      const senderId = req.user.id;

      const newMessage = new Message({
        conversationId,
        sender: senderId,
        text,
      });
      const savedMessage = await newMessage.save();
      res.status(StatusCodes.CREATED).json(savedMessage);
    } catch (error) {
      next(error);
    }
  }
};

export default chatController;
