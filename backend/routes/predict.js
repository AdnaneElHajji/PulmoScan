const router  = require('express').Router();
const auth    = require('../middleware/auth');
const predict = require('../controllers/predict.controller');

router.post('/', auth, predict.predict);

module.exports = router;
