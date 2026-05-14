const router   = require('express').Router();
const auth     = require('../controllers/auth.controller');
const validate = require('../middleware/validate');

router.post('/send-code',    auth.sendCode);
router.post('/verify-code',  auth.verifyCode);
router.post('/register',     validate.validateRegister, auth.register);
router.post('/login',        auth.login);

module.exports = router;
