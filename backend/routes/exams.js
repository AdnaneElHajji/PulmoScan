const router = require('express').Router();
const auth   = require('../middleware/auth');
const exam   = require('../controllers/exams.controller');

router.use(auth);

router.get('/',                        exam.getAll);
router.get('/patient/:patientId',      exam.getByPatient);
router.get('/:id',                     exam.getById);
router.post('/',                       exam.create);
router.put('/:id',                     exam.update);
router.delete('/:id',                  exam.remove);

module.exports = router;
