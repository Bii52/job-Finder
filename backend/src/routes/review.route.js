import express from 'express';
import reviewController from '../controllers/review.controller.js';
import { verifyToken } from '../middleware/auth.middleware.js';

const router = express.Router();

router.post('/', verifyToken, reviewController.createReview);
router.get('/:userId', verifyToken, reviewController.getReviewsForUser);

export default router;