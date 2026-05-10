const router = require('express').Router();
const pool   = require('../db');
const auth   = require('../middleware/auth');

router.use(auth);

// GET /api/results
router.get('/', async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT r.*, e.patient_id, e.image_path, p.nom AS patient_nom
       FROM resultats r
       JOIN examens e ON r.exam_id=e.id
       JOIN patients p ON e.patient_id=p.id
       ORDER BY r.date_analyse DESC`
    );
    res.json(rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// GET /api/results/:id
router.get('/:id', async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT r.*, e.patient_id, e.image_path, p.nom AS patient_nom
       FROM resultats r
       JOIN examens e ON r.exam_id=e.id
       JOIN patients p ON e.patient_id=p.id
       WHERE r.id=$1`,
      [req.params.id]
    );
    if (!rows.length) return res.status(404).json({ message: 'Résultat non trouvé' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// GET /api/results/exam/:examId
router.get('/exam/:examId', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT * FROM resultats WHERE exam_id=$1',
      [req.params.examId]
    );
    res.json(rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// POST /api/results
router.post('/', async (req, res) => {
  const { exam_id, diagnostic, confidence, severite, details } = req.body;
  if (!exam_id || !diagnostic || confidence === undefined || !severite)
    return res.status(400).json({ message: 'exam_id, diagnostic, confidence et severite sont obligatoires' });

  // Règle métier : confidence entre 0 et 1
  if (confidence < 0 || confidence > 1)
    return res.status(400).json({ message: 'La confidence doit être entre 0 et 1' });

  try {
    // Règle métier : l'examen doit exister
    const exam = await pool.query('SELECT id FROM examens WHERE id=$1', [exam_id]);
    if (!exam.rows.length)
      return res.status(404).json({ message: 'Examen non trouvé' });

    const { rows } = await pool.query(
      `INSERT INTO resultats (exam_id, diagnostic, confidence, severite, details, date_analyse)
       VALUES ($1,$2,$3,$4,$5,NOW()) RETURNING *`,
      [exam_id, diagnostic, confidence, severite, details || '']
    );

    // Met à jour le statut de l'examen automatiquement
    await pool.query("UPDATE examens SET statut='analyse' WHERE id=$1", [exam_id]);

    res.status(201).json(rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// DELETE /api/results/:id
router.delete('/:id', async (req, res) => {
  try {
    const exists = await pool.query('SELECT id FROM resultats WHERE id=$1', [req.params.id]);
    if (!exists.rows.length) return res.status(404).json({ message: 'Résultat non trouvé' });

    await pool.query('DELETE FROM resultats WHERE id=$1', [req.params.id]);
    res.json({ message: 'Résultat supprimé avec succès' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;
