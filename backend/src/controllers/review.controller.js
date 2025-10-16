import Review from '../models/review.model.js';
import { StatusCodes } from 'http-status-codes';
import ApiError from '../utils/ApiError.js';

const reviewController = {
  createReview: async (req, res, next) => {
    try {
      const { jobId, revieweeId, rating, comment } = req.body;
      const reviewerId = req.user.id;

      // Basic validation: A user cannot review themselves.
      if (reviewerId === revieweeId) {
        return next(new ApiError(StatusCodes.BAD_REQUEST, 'You cannot review yourself.'));
      }

      const newReview = new Review({
        job: jobId,
        reviewer: reviewerId,
        reviewee: revieweeId,
        rating,
        comment,
      });

      const savedReview = await newReview.save();
      res.status(StatusCodes.CREATED).json(savedReview);
    } catch (error) {
      next(error);
    }
  },

  getReviewsForUser: async (req, res, next) => {
    try {
      const reviews = await Review.find({ reviewee: req.params.userId }).populate('reviewer', 'name');
      res.status(StatusCodes.OK).json(reviews);
    } catch (error) {
      next(error);
    }
  },
};

export default reviewController;