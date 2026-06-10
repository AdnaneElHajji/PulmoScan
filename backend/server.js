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
app.use('/api/stats',    require('./routes/stats'));
app.use('/api/predict',  require('./routes/predict'));

app.get('/', (_, res) => res.send('PulmoScan API est opérationnelle !'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`Serveur lancé sur http://0.0.0.0:${PORT} (LAN: http://192.168.100.113:${PORT})`));
