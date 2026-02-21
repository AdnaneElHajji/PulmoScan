const express = require('express');
const app = express();

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'API PulmoScan OK' });
});

app.listen(3000, () => {
  console.log('Serveur lancé sur http://localhost:3000');
});