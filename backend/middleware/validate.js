const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

exports.validateRegister = (req, res, next) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password)
    return res.status(400).json({ message: 'Tous les champs sont obligatoires' });
  if (!emailRegex.test(email))
    return res.status(400).json({ message: 'Format email invalide' });
  if (password.length < 8)
    return res.status(400).json({ message: 'Mot de passe trop court (8 caractères minimum)' });
  next();
};

exports.validatePatient = (req, res, next) => {
  const { nom, age, genre, email, cin } = req.body;
  if (!nom || !age || !genre || !email || !cin)
    return res.status(400).json({ message: 'Nom, âge, genre, email et CIN sont obligatoires' });
  if (!emailRegex.test(email))
    return res.status(400).json({ message: 'Format email invalide' });
  if (age < 1 || age > 149)
    return res.status(400).json({ message: 'Âge invalide (1-149)' });
  next();
};

exports.validateExam = (req, res, next) => {
  const { patient_id, image_path } = req.body;
  if (!patient_id || !image_path)
    return res.status(400).json({ message: 'patient_id et image_path sont obligatoires' });
  next();
};

exports.validateResult = (req, res, next) => {
  const { exam_id, diagnostic, confidence, severite } = req.body;
  if (!exam_id || !diagnostic || confidence === undefined || !severite)
    return res.status(400).json({ message: 'exam_id, diagnostic, confidence et severite sont obligatoires' });
  if (confidence < 0 || confidence > 1)
    return res.status(400).json({ message: 'La confidence doit être entre 0 et 1' });
  const niveaux = ['faible', 'modere', 'severe', 'normal', 'moyen', 'urgent'];
  if (!niveaux.includes(severite))
    return res.status(400).json({ message: 'Sévérité invalide' });
  next();
};
