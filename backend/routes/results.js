const router   = require('express').Router();
const auth     = require('../middleware/auth');
const validate = require('../middleware/validate');
const result   = require('../controllers/results.controller');

router.use(auth);

router.get('/',              result.getAll);
router.get('/exam/:examId',  result.getByExam);
router.get('/:id',           result.getById);
router.post('/',             validate.validateResult, result.create);
router.delete('/:id',        result.remove);

module.exports = router;
