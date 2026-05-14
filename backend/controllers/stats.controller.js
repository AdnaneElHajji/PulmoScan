const pool = require('../db');

exports.getStats = async (req, res) => {
  try {
    const [patients, examens, resultats, parStatut, topDiagnostics] = await Promise.all([
      pool.query('SELECT COUNT(*) FROM patients'),
      pool.query('SELECT COUNT(*) FROM examens'),
      pool.query('SELECT COUNT(*) FROM resultats'),
      pool.query(`
        SELECT statut, COUNT(*) AS total
        FROM examens GROUP BY statut
      `),
      pool.query(`
        SELECT diagnostic, COUNT(*) AS total
        FROM resultats
        GROUP BY diagnostic
        ORDER BY total DESC
        LIMIT 5
      `),
    ]);

    res.json({
      total_patients:  parseInt(patients.rows[0].count),
      total_examens:   parseInt(examens.rows[0].count),
      total_resultats: parseInt(resultats.rows[0].count),
      examens_par_statut: parStatut.rows,
      top_diagnostics:    topDiagnostics.rows,
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};
