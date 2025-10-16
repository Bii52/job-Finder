import { userService } from '../service/user.service.js';

const registerUser = async (req, res, next) => {
    userService.registerUser(req, res, next);
};

const loginUser = async (req, res, next) => {
    userService.loginUser(req, res, next);
};

const forgotPassword = async (req, res, next) => {
    userService.forgotPassword(req, res, next);
};

const changePassword = async (req, res, next) => {
    userService.changePassword(req, res, next);
};

const getAllUsers = async (req, res, next) => {
    userService.getAllUsers(req, res, next);
};

const getUserById = async (req, res, next) => {
    userService.getUserById(req, res, next);
};

const updateUser = async (req, res, next) => {
    userService.updateUser(req, res, next);
};

const deleteUser = async (req, res, next) => {
    userService.deleteUser(req, res, next);
};


const getMe = async (req, res, next) => {
    userService.getMe(req, res, next);
};

const toggleFavorite = async (req, res, next) => {
    userService.toggleFavorite(req, res, next);
};


export default {
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