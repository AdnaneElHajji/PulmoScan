const WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const MAX_ATTEMPTS = 10;

const store = new Map();

// Cleans up expired windows to avoid unbounded memory growth
setInterval(() => {
  const now = Date.now();
  for (const [key, rec] of store.entries()) {
    if (now > rec.resetAt) store.delete(key);
  }
}, WINDOW_MS);

module.exports = (req, res, next) => {
  const key = `${req.ip}:${req.path}`;
  const now = Date.now();
  let rec = store.get(key);

  if (!rec || now > rec.resetAt) {
    rec = { count: 0, resetAt: now + WINDOW_MS };
  }

  rec.count++;
  store.set(key, rec);

  if (rec.count > MAX_ATTEMPTS) {
    return res.status(429).json({
      message: 'Trop de tentatives. Réessayez dans 15 minutes.',
    });
  }

  next();
};
