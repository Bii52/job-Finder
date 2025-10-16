import express from 'express';
import jobController from '../controllers/job.controller.js';
import { verifyToken, verifyEmployer, verifyJobOwner } from '../middleware/auth.middleware.js';

const router = express.Router();

router.post('/', [verifyToken, verifyEmployer], jobController.createJob);
router.get('/', verifyToken, jobController.getAllJobs);
router.get('/:id', verifyToken, jobController.getJobById);
router.get('/:id/apply', verifyToken, jobController.getApplicants);
router.put('/:id', [verifyToken, verifyEmployer, verifyJobOwner], jobController.updateJob);
router.delete('/:id', [verifyToken, verifyEmployer, verifyJobOwner], jobController.deleteJob);

export default router;