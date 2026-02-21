const bcrypt = require("bcrypt");

const users = []; // TEMPORAIRE (remplacé par DB après)

exports.register = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password)
    return res.status(400).json({ message: "Champs manquants" });

  const exists = users.find(u => u.email === email);
  if (exists)
    return res.status(409).json({ message: "Email déjà utilisé" });

  const hashedPassword = await bcrypt.hash(password, 10);

  users.push({ email, password: hashedPassword });

  res.status(201).json({ message: "Compte créé avec succès" });
};

exports.login = async (req, res) => {
  const { email, password } = req.body;

  const user = users.find(u => u.email === email);
  if (!user)
    return res.status(401).json({ message: "Utilisateur non trouvé" });

  const valid = await bcrypt.compare(password, user.password);
  if (!valid)
    return res.status(401).json({ message: "Mot de passe incorrect" });

  res.json({ message: "Connexion réussie" });
};
