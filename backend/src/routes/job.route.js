import express from 'express';
import jobController from '../controllers/job.controller.js';
import {
  verifyToken,
  verifyEmployer,
  verifyJobOwnerOrAdmin,
} from '../middleware/auth.middleware.js';

const router = express.Router();

// @route   POST api/jobs
// @desc    Create a new job
// @access  Private (Employer)
router.post('/', verifyToken, verifyEmployer, jobController.createJob);

// @route   GET api/jobs
// @desc    Get all jobs
// @access  Public
router.get('/', jobController.getAllJobs);

router.get('/:id', jobController.getJobById);
router.put('/:id', verifyToken, verifyJobOwnerOrAdmin, jobController.updateJob);
router.delete('/:id', verifyToken, verifyJobOwnerOrAdmin, jobController.deleteJob);
router.post('/:id/apply', verifyToken, jobController.applyForJob);
router.get('/:id/applicants', verifyToken, verifyJobOwnerOrAdmin, jobController.getApplicants);

export default router;