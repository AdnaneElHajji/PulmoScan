const router = require('express').Router();
const pool   = require('../db');
const auth   = require('../middleware/auth');

router.use(auth);

// GET /api/stats
// Statistiques globales pour le dashboard
router.get('/', async (req, res) => {
  try {
    const [
      totalPatients,
      totalExamens,
      examensMoisActuel,
      detectionsPositives,
      repartitionSeverite,
      examensRecents
    ] = await Promise.all([
      pool.query('SELECT COUNT(*) FROM patients'),
      pool.query('SELECT COUNT(*) FROM examens'),
      pool.query(
        `SELECT COUNT(*) FROM examens
         WHERE EXTRACT(MONTH FROM date_examen) = EXTRACT(MONTH FROM NOW())
         AND   EXTRACT(YEAR  FROM date_examen) = EXTRACT(YEAR  FROM NOW())`
      ),
      pool.query(`SELECT COUNT(*) FROM resultats WHERE diagnostic != 'Normal'`),
      pool.query(`SELECT severite, COUNT(*) AS count FROM resultats GROUP BY severite`),
      pool.query(
        `SELECT e.id, e.date_examen, e.statut, p.nom AS patient_nom, r.diagnostic
         FROM examens e
         JOIN patients p ON e.patient_id = p.id
         LEFT JOIN resultats r ON r.exam_id = e.id
         ORDER BY e.date_examen DESC
         LIMIT 5`
      )
    ]);

    res.json({
      totalPatients:        parseInt(totalPatients.rows[0].count),
      totalExamens:         parseInt(totalExamens.rows[0].count),
      examensMoisActuel:    parseInt(examensMoisActuel.rows[0].count),
      detectionsPositives:  parseInt(detectionsPositives.rows[0].count),
      repartitionSeverite:  repartitionSeverite.rows,
      examensRecents:       examensRecents.rows
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;
