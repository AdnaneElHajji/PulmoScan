// Simule une analyse IA de radiographie pulmonaire
// À remplacer par un vrai modèle TFLite quand disponible

const DISEASES = [
  { name: 'Pneumonie',          severity: 'modere' },
  { name: 'Tuberculose',        severity: 'severe' },
  { name: 'Épanchement pleural',severity: 'modere' },
  { name: 'Cardiomégalie',      severity: 'faible' },
  { name: 'Nodule pulmonaire',  severity: 'faible' },
  { name: 'Atélectasie',        severity: 'modere' },
  { name: 'Normal',             severity: 'faible' },
];

exports.predict = (req, res) => {
  const { image_path } = req.body;

  if (!image_path)
    return res.status(400).json({ message: 'image_path est obligatoire' });

  // Simulation : génère un résultat aléatoire avec score de confiance
  const disease    = DISEASES[Math.floor(Math.random() * DISEASES.length)];
  const confidence = parseFloat((0.70 + Math.random() * 0.28).toFixed(4));

  res.json({
    diagnostic:  disease.name,
    confidence,
    severite:    disease.severity,
    details:     `Analyse automatique de ${image_path} — modèle EfficientNetB0`,
    model:       'EfficientNetB0 (simulation)',
    analyzed_at: new Date().toISOString(),
  });
};
