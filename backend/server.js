require('dotenv').config();
const express = require('express');
const cors    = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Routes
app.use('/api',          require('./routes/auth'));
app.use('/api/patients', require('./routes/patients'));
app.use('/api/exams',    require('./routes/exams'));
app.use('/api/results',  require('./routes/results'));
app.use('/api/predict',  require('./routes/predict'));
app.use('/api/stats',    require('./routes/stats'));

// Sanity check
app.get('/', (_, res) => res.send('PulmoScan API v2 🚀'));

// Gestion globale des erreurs
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Erreur interne du serveur' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Serveur PulmoScan lancé sur http://localhost:${PORT}`));
