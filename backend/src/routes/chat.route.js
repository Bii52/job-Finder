import express from "express";
import chatController from "../controllers/chat.controller.js";
import { verifyToken } from "../middleware/auth.middleware.js";

const router = express.Router();

router.post("/", verifyToken, chatController.createConversation);
router.get("/", verifyToken, chatController.getConversations);
router.get("/:conversationId", verifyToken, chatController.getMessages);
router.post("/message", verifyToken, chatController.addMessage);

export default router;
