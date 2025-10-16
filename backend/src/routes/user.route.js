import express from "express";
import userController from "../controllers/user.controller.js";
import { verifyToken, verifyAdmin, verifyUserOrAdmin } from "../middleware/auth.middleware.js";

const router = express.Router();

router.post("/register", userController.registerUser);
router.post("/login", userController.loginUser);
router.post("/forgot-password", userController.forgotPassword);
router.post("/change-password/:id", verifyToken, userController.changePassword); // Should be protected
router.get("/me", verifyToken, userController.getMe);
router.get("/", verifyToken, verifyAdmin, userController.getAllUsers);
router.get("/:id", verifyToken, verifyAdmin,userController.getUserById);
router.put("/:id", verifyToken, verifyUserOrAdmin,userController.updateUser);
router.delete("/:id",verifyToken, verifyAdmin, userController.deleteUser);
router.post("/favorites/:jobId", verifyToken, userController.toggleFavorite);

export default router;