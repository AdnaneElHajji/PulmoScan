const router = require('express').Router();
const pool   = require('../db');
const auth   = require('../middleware/auth');

router.use(auth);

// GET /api/patients?search=nom
router.get('/', async (req, res) => {
  try {
    const { search } = req.query;
    let query  = 'SELECT * FROM patients';
    let params = [];

    if (search) {
      query += ' WHERE nom ILIKE $1 OR email ILIKE $1 OR cin ILIKE $1';
      params = [`%${search}%`];
    }

    query += ' ORDER BY date_creation DESC';

    const { rows } = await pool.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// GET /api/patients/:id
router.get('/:id', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM patients WHERE id=$1', [req.params.id]);
    if (!rows.length) return res.status(404).json({ message: 'Patient non trouvé' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// POST /api/patients
router.post('/', async (req, res) => {
  const { nom, age, genre, email, telephone, cin, antecedents } = req.body;
  if (!nom || !age || !genre || !email || !telephone || !cin || !antecedents)
    return res.status(400).json({ message: 'Tous les champs sont obligatoires' });

  try {
    // Règle métier : email unique
    const exists = await pool.query('SELECT id FROM patients WHERE email=$1', [email]);
    if (exists.rows.length)
      return res.status(409).json({ message: 'Un patient avec cet email existe déjà' });

    const { rows } = await pool.query(
      `INSERT INTO patients (nom, age, genre, email, telephone, cin, antecedents, date_creation)
       VALUES ($1,$2,$3,$4,$5,$6,$7,NOW()) RETURNING *`,
      [nom, age, genre, email, telephone, cin, antecedents]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// PUT /api/patients/:id
router.put('/:id', async (req, res) => {
  const { nom, age, genre, email, telephone, cin, antecedents } = req.body;
  if (!nom || !age || !genre || !email || !telephone || !cin || !antecedents)
    return res.status(400).json({ message: 'Tous les champs sont obligatoires' });

  try {
    const exists = await pool.query('SELECT id FROM patients WHERE id=$1', [req.params.id]);
    if (!exists.rows.length) return res.status(404).json({ message: 'Patient non trouvé' });

    // Règle métier : email unique (sauf pour ce patient)
    const emailTaken = await pool.query(
      'SELECT id FROM patients WHERE email=$1 AND id!=$2',
      [email, req.params.id]
    );
    if (emailTaken.rows.length)
      return res.status(409).json({ message: 'Cet email est déjà utilisé' });

    const { rows } = await pool.query(
      `UPDATE patients SET nom=$1,age=$2,genre=$3,email=$4,telephone=$5,cin=$6,antecedents=$7
       WHERE id=$8 RETURNING *`,
      [nom, age, genre, email, telephone, cin, antecedents, req.params.id]
    );
    res.json(rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// DELETE /api/patients/:id
router.delete('/:id', async (req, res) => {
  try {
    const exists = await pool.query('SELECT id FROM patients WHERE id=$1', [req.params.id]);
    if (!exists.rows.length) return res.status(404).json({ message: 'Patient non trouvé' });

    await pool.query('DELETE FROM patients WHERE id=$1', [req.params.id]);
    res.json({ message: 'Patient supprimé avec succès' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;
