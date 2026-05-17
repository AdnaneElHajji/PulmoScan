const nodemailer = require('nodemailer');

function createTransporter() {
  if (process.env.EMAIL_USER && process.env.EMAIL_PASS) {
    return nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
  }
  return null;
}

async function sendVerificationEmail(email, code) {
  const transporter = createTransporter();

  if (!transporter) {
    console.log(`\n╔════════════════════════════════╗`);
    console.log(`║  CODE DE VÉRIFICATION          ║`);
    console.log(`║  Email : ${email.padEnd(22)}║`);
    console.log(`║  Code  : ${code.padEnd(22)}║`);
    console.log(`╚════════════════════════════════╝\n`);
    return;
  }

  await transporter.sendMail({
    from: `"PulmoScan IA" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Votre code de vérification PulmoScan IA',
    html: `
      <div style="font-family:Arial,sans-serif;max-width:520px;margin:0 auto;">
        <div style="background:#0059FF;padding:24px;text-align:center;border-radius:12px 12px 0 0;">
          <h1 style="color:white;margin:0;font-size:22px;">PulmoScan IA</h1>
          <p style="color:#93C5FD;margin:6px 0 0;">Détection des maladies pulmonaires</p>
        </div>
        <div style="padding:32px;background:#f9fafb;border-radius:0 0 12px 12px;border:1px solid #e5e7eb;">
          <h2 style="color:#111827;margin-top:0;">Vérification de votre email</h2>
          <p style="color:#6B7280;">Utilisez ce code pour finaliser votre inscription :</p>
          <div style="background:white;border:2px solid #0059FF;border-radius:12px;padding:24px;text-align:center;margin:24px 0;">
            <span style="font-size:40px;font-weight:bold;letter-spacing:12px;color:#0059FF;">${code}</span>
          </div>
          <p style="color:#9CA3AF;font-size:13px;">⏰ Ce code expire dans <strong>10 minutes</strong>.</p>
          <p style="color:#9CA3AF;font-size:12px;">Si vous n'avez pas demandé ce code, ignorez cet email.</p>
        </div>
      </div>
    `,
  });
}

async function sendPasswordResetEmail(email, tempPassword) {
  const transporter = createTransporter();

  if (!transporter) {
    console.log(`\n╔════════════════════════════════╗`);
    console.log(`║  MOT DE PASSE TEMPORAIRE       ║`);
    console.log(`║  Email : ${email.padEnd(22)}║`);
    console.log(`║  Temp  : ${tempPassword.padEnd(22)}║`);
    console.log(`╚════════════════════════════════╝\n`);
    return;
  }

  await transporter.sendMail({
    from: `"PulmoScan IA" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Réinitialisation de votre mot de passe PulmoScan IA',
    html: `
      <div style="font-family:Arial,sans-serif;max-width:520px;margin:0 auto;">
        <div style="background:#0059FF;padding:24px;text-align:center;border-radius:12px 12px 0 0;">
          <h1 style="color:white;margin:0;font-size:22px;">PulmoScan IA</h1>
          <p style="color:#93C5FD;margin:6px 0 0;">Détection des maladies pulmonaires</p>
        </div>
        <div style="padding:32px;background:#f9fafb;border-radius:0 0 12px 12px;border:1px solid #e5e7eb;">
          <h2 style="color:#111827;margin-top:0;">Réinitialisation du mot de passe</h2>
          <p style="color:#6B7280;">Voici votre mot de passe temporaire :</p>
          <div style="background:white;border:2px solid #0059FF;border-radius:12px;padding:24px;text-align:center;margin:24px 0;">
            <span style="font-size:24px;font-weight:bold;letter-spacing:4px;color:#0059FF;font-family:monospace;">${tempPassword}</span>
          </div>
          <p style="color:#374151;font-size:14px;">Connectez-vous avec ce mot de passe, puis changez-le immédiatement depuis votre profil.</p>
          <p style="color:#9CA3AF;font-size:12px;">Si vous n'avez pas demandé cette réinitialisation, contactez le support immédiatement.</p>
        </div>
      </div>
    `,
  });
}

module.exports = { sendVerificationEmail, sendPasswordResetEmail };
