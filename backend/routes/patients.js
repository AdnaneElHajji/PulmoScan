const router   = require('express').Router();
const auth     = require('../middleware/auth');
const validate = require('../middleware/validate');
const patient  = require('../controllers/patients.controller');

router.use(auth);

router.get('/',      patient.getAll);
router.get('/:id',   patient.getById);
router.post('/',     validate.validatePatient, patient.create);
router.put('/:id',   validate.validatePatient, patient.update);
router.delete('/:id', patient.remove);

module.exports = router;
