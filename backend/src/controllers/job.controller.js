import Job from '../models/job.model.js';
import { StatusCodes } from 'http-status-codes';
import ApiError from '../utils/ApiError.js';

const jobController = {
  createJob: async (req, res, next) => {
    try {
      const { title, description, company, location, salary, skills } = req.body;
      const newJob = new Job({
        title,
        description,
        company,
        location,
        salary,
        skills,
        employer: req.user.id,
      });
      const savedJob = await newJob.save();
      res.status(StatusCodes.CREATED).json(savedJob);
    } catch (error) {
      next(error);
    }
  },

  getAllJobs: async (req, res, next) => {
    try {
      const jobs = await Job.find().populate('employer', 'name email');
      res.status(StatusCodes.OK).json(jobs);
    } catch (error) {
      next(error);
    }
  },

  getJobById: async (req, res, next) => {
    try {
      const job = await Job.findById(req.params.id).populate('employer', 'name email');
      if (!job) {
        throw new ApiError(StatusCodes.NOT_FOUND, 'Không tìm thấy công việc');
      }
      res.status(StatusCodes.OK).json(job);
    } catch (error) {
      next(error);
    }
  },

  updateJob: async (req, res, next) => {
    try {
      const updatedJob = await Job.findByIdAndUpdate(req.params.id, req.body, { new: true });
      res.status(StatusCodes.OK).json(updatedJob);
    } catch (error) {
      next(error);
    }
  },

  deleteJob: async (req, res, next) => {
    try {
      await Job.findByIdAndDelete(req.params.id);
      res.status(StatusCodes.OK).json({ message: 'Xóa công việc thành công' });
    } catch (error) {
      next(error);
    }
  },

  applyForJob: async (req, res, next) => {
    try {
      const job = await Job.findById(req.params.id);
      if (!job) {
        return next(new ApiError(StatusCodes.NOT_FOUND, 'Không tìm thấy công việc'));
      }

      // Kiểm tra xem người dùng có phải là nhà tuyển dụng của công việc này không
      if (job.employer.toString() === req.user.id) {
        return next(new ApiError(StatusCodes.BAD_REQUEST, 'Bạn không thể ứng tuyển vào công việc của chính mình'));
      }

      // Kiểm tra xem người dùng đã ứng tuyển chưa
      if (job.applicants.some(applicant => applicant.user.toString() === req.user.id)) {
        return next(new ApiError(StatusCodes.BAD_REQUEST, 'Bạn đã ứng tuyển vào công việc này rồi'));
      }

      job.applicants.push({ user: req.user.id });
      await job.save();

      res.status(StatusCodes.CREATED).json({ message: 'Ứng tuyển thành công' });
    } catch (error) {
      next(error);
    }
  },

  getApplicants: async (req, res, next) => {
    try {
      const job = await Job.findById(req.params.id).populate('applicants.user', 'name email role');
      res.status(StatusCodes.OK).json(job.applicants);
    } catch (error) {
      next(error);
    }
  },

  inviteToApply: async (req, res, next) => {
    try {
      const { jobId } = req.body; // Employer will select a job to invite for
      const jobSeekerId = req.params.id; // The user being invited

      const job = await Job.findById(jobId);
      if (!job) {
        return next(new ApiError(StatusCodes.NOT_FOUND, 'Không tìm thấy công việc'));
      }

      // Check if the person making the request is the employer for this job
      if (job.employer.toString() !== req.user.id) {
        return next(new ApiError(StatusCodes.FORBIDDEN, 'Bạn không có quyền mời ứng viên cho công việc này'));
      }

      const jobSeeker = await User.findById(jobSeekerId);
      if (!jobSeeker || jobSeeker.role !== 'job_seeker') {
        return next(new ApiError(StatusCodes.BAD_REQUEST, 'Chỉ có thể mời người tìm việc'));
      }

      // Check if user has already applied
      if (job.applicants.some(applicant => applicant.user.toString() === jobSeekerId)) {
        return next(new ApiError(StatusCodes.BAD_REQUEST, 'Người dùng này đã ứng tuyển vào công việc'));
      }

      res.status(StatusCodes.OK).json({ message: 'Lời mời đã được gửi thành công (chức năng đang phát triển)' });
    } catch (error) {
      next(error);
    }
  }
};

export default jobController;