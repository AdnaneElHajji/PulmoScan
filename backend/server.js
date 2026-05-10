require('dotenv').config();
const express = require('express');
const cors    = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api',          require('./routes/auth'));
app.use('/api/patients', require('./routes/patients'));
app.use('/api/exams',    require('./routes/exams'));
app.use('/api/results',  require('./routes/results'));

app.get('/', (_, res) => res.send('PulmoScan API 🚀'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Serveur lancé sur http://localhost:${PORT}`));
