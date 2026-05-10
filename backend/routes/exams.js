const router = require('express').Router();
const pool   = require('../db');
const auth   = require('../middleware/auth');

router.use(auth);

// GET /api/exams
router.get('/', async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT e.*, p.nom AS patient_nom
       FROM examens e JOIN patients p ON e.patient_id=p.id
       ORDER BY e.date_examen DESC`
    );
    res.json(rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// GET /api/exams/:id
router.get('/:id', async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT e.*, p.nom AS patient_nom
       FROM examens e JOIN patients p ON e.patient_id=p.id
       WHERE e.id=$1`,
      [req.params.id]
    );
    if (!rows.length) return res.status(404).json({ message: 'Examen non trouvé' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// GET /api/exams/patient/:patientId
router.get('/patient/:patientId', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT * FROM examens WHERE patient_id=$1 ORDER BY date_examen DESC',
      [req.params.patientId]
    );
    res.json(rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// POST /api/exams
router.post('/', async (req, res) => {
  const { patient_id, image_path, notes, statut } = req.body;
  if (!patient_id || !image_path)
    return res.status(400).json({ message: 'patient_id et image_path sont obligatoires' });

  try {
    // Règle métier : le patient doit exister
    const patient = await pool.query('SELECT id FROM patients WHERE id=$1', [patient_id]);
    if (!patient.rows.length)
      return res.status(404).json({ message: 'Patient non trouvé' });

    const { rows } = await pool.query(
      `INSERT INTO examens (patient_id, image_path, notes, date_examen, statut)
       VALUES ($1,$2,$3,NOW(),$4) RETURNING *`,
      [patient_id, image_path, notes || '', statut || 'en_attente']
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// PUT /api/exams/:id
router.put('/:id', async (req, res) => {
  const { notes, statut } = req.body;
  try {
    const exists = await pool.query('SELECT id FROM examens WHERE id=$1', [req.params.id]);
    if (!exists.rows.length) return res.status(404).json({ message: 'Examen non trouvé' });

    const { rows } = await pool.query(
      'UPDATE examens SET notes=$1, statut=$2 WHERE id=$3 RETURNING *',
      [notes, statut, req.params.id]
    );
    res.json(rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// DELETE /api/exams/:id
router.delete('/:id', async (req, res) => {
  try {
    const exists = await pool.query('SELECT id FROM examens WHERE id=$1', [req.params.id]);
    if (!exists.rows.length) return res.status(404).json({ message: 'Examen non trouvé' });

    await pool.query('DELETE FROM examens WHERE id=$1', [req.params.id]);
    res.json({ message: 'Examen supprimé avec succès' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;
