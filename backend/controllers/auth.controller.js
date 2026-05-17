const crypto = require('crypto');
const bcrypt  = require('bcryptjs');
const jwt     = require('jsonwebtoken');
const pool    = require('../db');
const { sendVerificationEmail, sendPasswordResetEmail } = require('../services/email');

// Codes en mémoire : email → { code, expiry }
const pendingCodes = new Map();

// ── Envoyer un code de vérification ──────────────────────────────────────────
exports.sendCode = async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ message: 'Email obligatoire' });

  const code   = Math.floor(100000 + Math.random() * 900000).toString();
  const expiry = Date.now() + 10 * 60 * 1000;
  pendingCodes.set(email, { code, expiry });

  try {
    await sendVerificationEmail(email, code);
    res.json({ message: 'Code de vérification envoyé' });
  } catch (err) {
    console.error('Email error:', err.message);
    res.status(500).json({ message: 'Erreur lors de l\'envoi du code' });
  }
};

// ── Vérifier le code ──────────────────────────────────────────────────────────
exports.verifyCode = (req, res) => {
  const { email, code } = req.body;
  if (!email || !code)
    return res.status(400).json({ message: 'Email et code obligatoires' });

  const stored = pendingCodes.get(email);
  if (!stored)
    return res.status(400).json({ message: 'Aucun code envoyé pour cet email' });

  if (Date.now() > stored.expiry) {
    pendingCodes.delete(email);
    return res.status(400).json({ message: 'Code expiré, demandez un nouveau code' });
  }

  if (stored.code !== code.toString())
    return res.status(400).json({ message: 'Code incorrect' });

  pendingCodes.delete(email);
  res.json({ message: 'Email vérifié avec succès' });
};

// ── Inscription ───────────────────────────────────────────────────────────────
exports.register = async (req, res) => {
  const { name, email, password, role } = req.body;
  try {
    const exists = await pool.query('SELECT id FROM users WHERE email=$1', [email]);
    if (exists.rows.length)
      return res.status(409).json({ message: 'Email déjà utilisé' });

    const hash = await bcrypt.hash(password, 10);
    const { rows } = await pool.query(
      'INSERT INTO users (name, email, password, role) VALUES ($1,$2,$3,$4) RETURNING id, name, email, role',
      [name, email, hash, role || 'medecin']
    );
    res.status(201).json({ message: 'Compte créé avec succès', user: rows[0] });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// ── Connexion ─────────────────────────────────────────────────────────────────
exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const { rows } = await pool.query('SELECT * FROM users WHERE email=$1', [email]);
    const user = rows[0];
    if (!user)
      return res.status(401).json({ message: 'Utilisateur non trouvé' });

    if (!await bcrypt.compare(password, user.password))
      return res.status(401).json({ message: 'Mot de passe incorrect' });

    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );
    res.json({
      message: 'Connexion réussie',
      token,
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// ── Mot de passe oublié ───────────────────────────────────────────────────────
// Never reveals whether the email exists (anti-enumeration).
exports.forgotPassword = async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ message: 'Email obligatoire' });

  const genericResponse = { message: 'Si ce compte existe, un email a été envoyé.' };

  try {
    const { rows } = await pool.query('SELECT id FROM users WHERE email=$1', [email]);
    if (!rows.length) return res.json(genericResponse);

    // Generate a cryptographically secure temporary password (12 hex chars)
    const tempPassword = crypto.randomBytes(6).toString('hex');
    const hash = await bcrypt.hash(tempPassword, 10);

    await pool.query('UPDATE users SET password=$1 WHERE email=$2', [hash, email]);
    await sendPasswordResetEmail(email, tempPassword);

    res.json(genericResponse);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// ── Changer le mot de passe ───────────────────────────────────────────────────
exports.changePassword = async (req, res) => {
  const { oldPassword, newPassword } = req.body;

  if (!oldPassword || !newPassword)
    return res.status(400).json({ message: 'Ancien et nouveau mot de passe obligatoires' });

  if (newPassword.length < 8)
    return res.status(400).json({ message: 'Le nouveau mot de passe doit contenir au moins 8 caractères' });

  try {
    const { rows } = await pool.query('SELECT * FROM users WHERE id=$1', [req.user.id]);
    const user = rows[0];
    if (!user) return res.status(404).json({ message: 'Utilisateur introuvable' });

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch)
      return res.status(401).json({ message: 'Mot de passe actuel incorrect' });

    const hash = await bcrypt.hash(newPassword, 10);
    await pool.query('UPDATE users SET password=$1 WHERE id=$2', [hash, req.user.id]);

    res.json({ message: 'Mot de passe mis à jour avec succès' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};
