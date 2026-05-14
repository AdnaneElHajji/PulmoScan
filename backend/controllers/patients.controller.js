const pool = require('../db');

exports.getAll = async (req, res) => {
  try {
    const search = req.query.search || '';
    const { rows } = await pool.query(
      `SELECT * FROM patients
       WHERE nom ILIKE $1 OR email ILIKE $1
       ORDER BY date_creation DESC`,
      [`%${search}%`]
    );
    res.json(rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.getById = async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM patients WHERE id=$1', [req.params.id]);
    if (!rows.length) return res.status(404).json({ message: 'Patient non trouvé' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.create = async (req, res) => {
  const { nom, age, genre, email, telephone, cin, antecedents } = req.body;
  try {
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
};

exports.update = async (req, res) => {
  const { nom, age, genre, email, telephone, cin, antecedents } = req.body;
  try {
    const exists = await pool.query('SELECT id FROM patients WHERE id=$1', [req.params.id]);
    if (!exists.rows.length) return res.status(404).json({ message: 'Patient non trouvé' });

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
};

exports.remove = async (req, res) => {
  try {
    const exists = await pool.query('SELECT id FROM patients WHERE id=$1', [req.params.id]);
    if (!exists.rows.length) return res.status(404).json({ message: 'Patient non trouvé' });

    await pool.query('DELETE FROM patients WHERE id=$1', [req.params.id]);
    res.json({ message: 'Patient supprimé avec succès' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};
