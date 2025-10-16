import User from '../models/user.model.js';
import bcrypt from 'bcryptjs';
import { jwtGenerate } from '../utils/jwt.js';
import ApiError from '../utils/ApiError.js';
import { StatusCodes } from 'http-status-codes';
import { hashPassword } from '../utils/password.js';

const registerUser = async (req, res, next) => {
  try {
    const { name, email, password, role } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'Email đã tồn tại'));
    }

    const hashedPassword = await hashPassword(password);

    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      role,
    });

    // User.create sẽ ném lỗi nếu thất bại, nên không cần kiểm tra if (user)
    res.status(StatusCodes.CREATED).json({
      message: 'Đăng ký thành công',
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
      token: jwtGenerate({ id: user._id, role: user.role }),
    });
  } catch (error) {
    next(error);
  }
};

const loginUser = async (req, res, next) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email }).select('-password');

        if (user && (await bcrypt.compare(password, (await User.findOne({ email })).password))) {
            res.status(StatusCodes.OK).json({
                message: "Đăng nhập thành công",
                user: user,
                token: jwtGenerate({ id: user._id, role: user.role })
            });
        } else {
            return next(new ApiError(StatusCodes.UNAUTHORIZED, 'Email hoặc mật khẩu không đúng'));
        }
    } catch (error) {
        next(error);
    }
};

const forgotPassword = async (req, res, next) => {
  try {
    const { email, newPassword } = req.body;
    const user = await User.findOne({ email });

    if (!user) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'Không tìm thấy người dùng với email này'));
    } 
    user.password = await hashPassword(newPassword);
    await user.save();
    res.status(StatusCodes.OK).json({ message: 'Mật khẩu đã được thay đổi thành công' });
  } catch (error) {
    next(error);
  }
};

const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const user = await User.findById(req.user._id);
    if (!user) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'Người dùng không tồn tại'));
    }
    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return next(new ApiError(StatusCodes.UNAUTHORIZED, 'Mật khẩu hiện tại không đúng'));
    }
    user.password = await hashPassword(newPassword);
    await user.save();
    res.status(StatusCodes.OK).json({ message: 'Mật khẩu đã được thay đổi thành công' });
  } catch (error) {
    next(error);
  }
};

const getUserById = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (user) {
      res.status(StatusCodes.OK).json(user);
    }
    else {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'Không tìm thấy người dùng'));
    }
  } catch (error) {
    next(error);
  } 
};

const updateUser = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (user) {
      if (req.body.role && req.user.role !== 'admin') {
        return next(new ApiError(StatusCodes.FORBIDDEN, 'Bạn không có quyền thay đổi vai trò người dùng.'));
      }
      user.name = req.body.name || user.name;
      user.email = req.body.email || user.email;
      user.role = req.body.role || user.role;
      const updatedUser = await user.save();
      res.status(StatusCodes.OK).json({
        _id: updatedUser._id,
        name: updatedUser.name,
        email: updatedUser.email,
        role: updatedUser.role,
      });
    } else {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'Không tìm thấy người dùng'));
    }
  } catch (error) {
    next(error);
  }
};


const getAllUsers = async (req, res, next) => {
  try {
    const users = await User.find({}).select('-password');
    res.status(StatusCodes.OK).json(users);
  } catch (error) {
    next(error);
  }
};

const deleteUser = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);

    if (user) {
      // Prevent admin from deleting themselves
      if (user._id.toString() === req.user._id.toString()) {
        return next(new ApiError(StatusCodes.BAD_REQUEST, 'Admin không thể tự xóa tài khoản.'));
      }
      await user.deleteOne();
      res.status(StatusCodes.OK).json({ message: 'Người dùng đã được xóa' });
    } else {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'Không tìm thấy người dùng'));
    }
  } catch (error) {
    next(error);
  }
};


const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).populate('favorites');
    if (!user) {
        return next(new ApiError(StatusCodes.NOT_FOUND, 'User not found'));
    }
    res.status(StatusCodes.OK).json(user);
  } catch (error) {
    next(error);
  }
};

const toggleFavorite = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { jobId } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'User not found'));
    }

    const jobIndex = user.favorites.indexOf(jobId);

    if (jobIndex === -1) {
      // Add to favorites
      user.favorites.push(jobId);
    } else {
      // Remove from favorites
      user.favorites.splice(jobIndex, 1);
    }

    await user.save();
    const updatedUser = await User.findById(userId).populate('favorites');
    res.status(StatusCodes.OK).json(updatedUser);
  } catch (error) {
    next(error);
  }
};

export const userService = {
  registerUser,
  loginUser,
  forgotPassword,
  changePassword,
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser,
  getMe,
  toggleFavorite,
};