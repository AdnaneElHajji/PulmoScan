const router       = require('express').Router();
const auth         = require('../controllers/auth.controller');
const validate     = require('../middleware/validate');
const authMiddleware = require('../middleware/auth');

router.post('/send-code',       auth.sendCode);
router.post('/verify-code',     auth.verifyCode);
router.post('/register',        validate.validateRegister, auth.register);
router.post('/login',           auth.login);
router.post('/forgot-password', auth.forgotPassword);
router.put('/change-password',  authMiddleware, auth.changePassword);

module.exports = router;
