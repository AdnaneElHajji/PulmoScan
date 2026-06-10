const router       = require('express').Router();
const auth         = require('../controllers/auth.controller');
const validate     = require('../middleware/validate');
const authMiddleware = require('../middleware/auth');
const rateLimiter  = require('../middleware/rateLimiter');

router.post('/send-code',       rateLimiter, auth.sendCode);
router.post('/verify-code',     auth.verifyCode);
router.post('/register',        validate.validateRegister, auth.register);
router.post('/login',           rateLimiter, auth.login);
router.post('/forgot-password', rateLimiter, auth.forgotPassword);
router.put('/change-password',  authMiddleware, auth.changePassword);

module.exports = router;
