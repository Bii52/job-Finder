import jwt from 'jsonwebtoken';

export const jwtGenerate = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: '1d',
  });
};

export const jwtVerify = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};