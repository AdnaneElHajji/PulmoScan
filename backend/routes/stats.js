const router = require('express').Router();
const auth   = require('../middleware/auth');
const stats  = require('../controllers/stats.controller');

router.get('/', auth, stats.getStats);

module.exports = router;
