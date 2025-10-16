import { jwtVerify } from '../utils/jwt.js'
import { StatusCodes } from 'http-status-codes'
import ApiError from '../utils/ApiError.js'
import User from '../models/user.model.js'
import Job from '../models/job.model.js'

export const verifyToken = async (req, res, next) => {
  let token;
  const authHeader = req.headers.authorization;

  if (authHeader && authHeader.startsWith('Bearer ')) {
    token = authHeader.split(' ')[1];
  }

  if (!token) return next(new ApiError(StatusCodes.UNAUTHORIZED, 'Token không được cung cấp hoặc không hợp lệ'));

  try {
    const decodedToken = jwtVerify(token)
    // Lấy thông tin user từ DB để đảm bảo dữ liệu luôn mới nhất
    const user = await User.findById(decodedToken.id).select('-password')

    if (!user) {
      return next(new ApiError(StatusCodes.UNAUTHORIZED, 'Người dùng không tồn tại'))
    }
    req.user = user // Gán object user từ DB vào request
    next()
  } catch (err) {
    next(new ApiError(StatusCodes.UNAUTHORIZED, 'Token không hợp lệ hoặc đã hết hạn'))
  }
}

export const verifyAdmin = (req, res, next) => {
  if (!req.user || !req.user.role || req.user.role !== 'admin') {
    return next(new ApiError(StatusCodes.FORBIDDEN, 'Bạn không có quyền truy cập'))
  }
  next()
}

export const verifyUserOrAdmin = (req, res, next) => {
  if (req.user.role === 'admin' || req.user.id === req.params.id) {
    next();
  } else {
    return next(new ApiError(StatusCodes.FORBIDDEN, 'Bạn không có quyền truy cập'));
  }
};

export const verifyEmployer = (req, res, next) => {
  if (req.user.role !== 'employer') {
    return next(new ApiError(StatusCodes.FORBIDDEN, 'Bạn không có quyền truy cập'));
  }
  next();
};

export const verifyJobOwner = async (req, res, next) => {
  try {
    const job = await Job.findById(req.params.id);
    if (!job) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'Không tìm thấy công việc'));
    }
    if (job.employer.toString() !== req.user.id) {
      return next(new ApiError(StatusCodes.FORBIDDEN, 'Bạn không có quyền chỉnh sửa công việc này'));
    }
    next();
  } catch (error) {
    next(error);
  }
};

export const verifyJobOwnerOrAdmin = async (req, res, next) => {
  try {
    if (req.user.role === 'admin') {
      return next(); // Admin có thể đi tiếp
    }
    const job = await Job.findById(req.params.id);
    if (!job) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'Không tìm thấy công việc'));
    }
    if (job.employer.toString() !== req.user.id) {
      return next(new ApiError(StatusCodes.FORBIDDEN, 'Bạn không có quyền thực hiện hành động này'));
    }
    next();
  } catch (error) {
    next(error);
  }
};