import 'package:flutter/material.dart';

class S {
  static Locale _locale = const Locale('fr');

  static void setLocale(Locale locale) => _locale = locale;
  static Locale get locale => _locale;
  static bool get isArabic => _locale.languageCode == 'ar';
  static TextDirection get dir =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  // ── Lookup ────────────────────────────────────────────────────────────────
  static String _t(String fr, String en, String ar) {
    switch (_locale.languageCode) {
      case 'en':
        return en;
      case 'ar':
        return ar;
      default:
        return fr;
    }
  }

  // ── App ───────────────────────────────────────────────────────────────────
  static String get appTitle => 'PulmoScan IA';
  static String get appSubtitle => _t(
        'Détection des maladies pulmonaires',
        'Pulmonary disease detection',
        'كشف أمراض الرئة',
      );
  static String get reservedAccess => _t(
        'Accès réservé aux professionnels de santé',
        'Access reserved for healthcare professionals',
        'الوصول مخصص للمختصين الصحيين',
      );

  // ── Auth ──────────────────────────────────────────────────────────────────
  static String get email =>
      _t('Email', 'Email', 'البريد الإلكتروني');
  static String get emailHint =>
      _t('docteur@hopital.ma', 'doctor@hospital.com', 'طبيب@مستشفى.ما');
  static String get password =>
      _t('Mot de passe', 'Password', 'كلمة المرور');
  static String get rememberMe =>
      _t('Se souvenir', 'Remember me', 'تذكرني');
  static String get forgotPassword =>
      _t('Mot de passe oublié ?', 'Forgot password?', 'نسيت كلمة المرور؟');
  static String get signIn =>
      _t('Se connecter', 'Sign in', 'تسجيل الدخول');
  static String get notRegistered =>
      _t('Pas encore inscrit ? ', 'Not registered? ', 'غير مسجل؟ ');
  static String get registerHere =>
      _t("S'inscrire ici", 'Register here', 'سجل هنا');
  static String get emailRequired =>
      _t('Email obligatoire', 'Email required', 'البريد الإلكتروني مطلوب');
  static String get emailInvalid =>
      _t('Email invalide', 'Invalid email', 'بريد إلكتروني غير صالح');
  static String get passwordRequired =>
      _t('Mot de passe obligatoire', 'Password required', 'كلمة المرور مطلوبة');
  static String get passwordMin =>
      _t('Minimum 6 caractères', 'Minimum 6 characters', 'الحد الأدنى 6 أحرف');

  // ── Register ──────────────────────────────────────────────────────────────
  static String get createAccount =>
      _t('Créer un compte', 'Create account', 'إنشاء حساب');
  static String get fullName =>
      _t('Nom complet', 'Full name', 'الاسم الكامل');
  static String get fullNameHint =>
      _t('Dr. Nom Prénom', 'Dr. First Last', 'د. الاسم الكامل');
  static String get specialty =>
      _t('Spécialité', 'Specialty', 'التخصص');
  static String get confirmPassword =>
      _t('Confirmer le mot de passe', 'Confirm password', 'تأكيد كلمة المرور');
  static String get register =>
      _t("S'inscrire", 'Register', 'تسجيل');
  static String get alreadyRegistered =>
      _t('Déjà inscrit ? ', 'Already registered? ', 'مسجل بالفعل؟ ');
  static String get signInHere =>
      _t('Se connecter', 'Sign in', 'تسجيل الدخول');
  static String get nameRequired =>
      _t('Nom obligatoire', 'Name required', 'الاسم مطلوب');
  static String get specialtyRequired =>
      _t('Spécialité obligatoire', 'Specialty required', 'التخصص مطلوب');
  static String get passwordMin8 =>
      _t('Minimum 8 caractères', 'Minimum 8 characters', 'الحد الأدنى 8 أحرف');
  static String get passwordMismatch =>
      _t('Les mots de passe ne correspondent pas',
          'Passwords do not match', 'كلمتا المرور غير متطابقتين');
  static String get confirmRequired =>
      _t('Confirmation obligatoire', 'Confirmation required', 'التأكيد مطلوب');

  // ── Specialties ───────────────────────────────────────────────────────────
  static List<Map<String, String>> get specialties => [
        {
          'value': 'MEDECIN_GENERALISTE',
          'label': _t('Médecin généraliste', 'General practitioner', 'طبيب عام'),
        },
        {
          'value': 'PNEUMOLOGUE',
          'label': _t('Pneumologue', 'Pulmonologist', 'طبيب الرئة'),
        },
        {
          'value': 'RADIOLOGUE',
          'label': _t('Radiologue', 'Radiologist', 'طبيب الأشعة'),
        },
        {
          'value': 'URGENTISTE',
          'label': _t('Urgentiste', 'Emergency physician', 'طبيب الطوارئ'),
        },
        {
          'value': 'INTERNISTE',
          'label': _t('Interniste', 'Internist', 'طبيب باطني'),
        },
        {
          'value': 'AUTRE',
          'label': _t('Autre spécialité', 'Other specialty', 'تخصص آخر'),
        },
      ];

  // ── Profile ───────────────────────────────────────────────────────────────
  static String get profile =>
      _t('Profil', 'Profile', 'الملف الشخصي');
  static String get settings =>
      _t('PARAMÈTRES', 'SETTINGS', 'الإعدادات');
  static String get about =>
      _t('À PROPOS', 'ABOUT', 'حول التطبيق');
  static String get changePassword =>
      _t('Changer le mot de passe', 'Change password', 'تغيير كلمة المرور');
  static String get secureAccount =>
      _t('Sécurisez votre compte', 'Secure your account', 'أمّن حسابك');
  static String get notifications =>
      _t('Notifications', 'Notifications', 'الإشعارات');
  static String get managePrefs =>
      _t('Gérer les préférences', 'Manage preferences', 'إدارة التفضيلات');
  static String get appVersion =>
      _t("Version de l'application", 'App version', 'إصدار التطبيق');
  static String get logout =>
      _t('Déconnexion', 'Logout', 'تسجيل الخروج');
  static String get logoutConfirm =>
      _t('Êtes-vous sûr de vouloir vous déconnecter ?',
          'Are you sure you want to log out?', 'هل أنت متأكد من تسجيل الخروج؟');
  static String get language =>
      _t('Langue', 'Language', 'اللغة');
  static String get cancel =>
      _t('Annuler', 'Cancel', 'إلغاء');
  static String get confirm =>
      _t('Confirmer', 'Confirm', 'تأكيد');
  static String get comingSoon =>
      _t('Fonctionnalité bientôt disponible',
          'Feature coming soon', 'الميزة قادمة قريباً');
  static String get currentPassword =>
      _t('MOT DE PASSE ACTUEL', 'CURRENT PASSWORD', 'كلمة المرور الحالية');
  static String get newPassword =>
      _t('NOUVEAU MOT DE PASSE', 'NEW PASSWORD', 'كلمة المرور الجديدة');
  static String get confirmPasswordLabel =>
      _t('CONFIRMER LE MOT DE PASSE', 'CONFIRM PASSWORD', 'تأكيد كلمة المرور');
  static String get currentPasswordRequired =>
      _t('Mot de passe actuel obligatoire',
          'Current password required', 'كلمة المرور الحالية مطلوبة');
  static String get newPasswordRequired =>
      _t('Nouveau mot de passe obligatoire',
          'New password required', 'كلمة المرور الجديدة مطلوبة');
  static String get passwordUpdated =>
      _t('Mot de passe mis à jour', 'Password updated', 'تم تحديث كلمة المرور');
  static String get currentPasswordWrong =>
      _t('Mot de passe actuel incorrect',
          'Current password incorrect', 'كلمة المرور الحالية غير صحيحة');

  // ── Navigation ────────────────────────────────────────────────────────────
  static String get navHome =>
      _t('Accueil', 'Home', 'الرئيسية');
  static String get navPatients =>
      _t('Patients', 'Patients', 'المرضى');
  static String get navHistory =>
      _t('Historique', 'History', 'التاريخ');
  static String get navProfile =>
      _t('Profil', 'Profile', 'الملف');

  // ── Verification ──────────────────────────────────────────────────────────
  static String get emailVerification =>
      _t('Vérification email', 'Email verification', 'التحقق من البريد');
  static String get codeSentTo =>
      _t('Un code à 6 chiffres a été envoyé à',
          'A 6-digit code was sent to', 'تم إرسال رمز مكون من 6 أرقام إلى');
  static String get verifyCreate =>
      _t('Vérifier et créer le compte',
          'Verify and create account', 'تحقق وأنشئ الحساب');
  static String get notReceived =>
      _t('Pas reçu ? ', "Didn't receive? ", 'لم تستلم؟ ');
  static String get resendCode =>
      _t('Renvoyer le code', 'Resend code', 'أعد إرسال الرمز');
  static String get sending =>
      _t('Envoi...', 'Sending...', 'جاري الإرسال...');
  static String get modifyEmail =>
      _t("← Modifier l'email", '← Modify email', '← تعديل البريد');
  static String get enterSixDigits =>
      _t('Entrez les 6 chiffres du code',
          'Enter the 6-digit code', 'أدخل الرمز المكون من 6 أرقام');
  static String get accountCreated =>
      _t('Compte créé avec succès ! Connectez-vous.',
          'Account created! Please sign in.',
          'تم إنشاء الحساب! سجل دخولك.');
  static String get codeSent =>
      _t('Nouveau code envoyé', 'New code sent', 'تم إرسال رمز جديد');

  // ── Forgot password dialog ────────────────────────────────────────────────
  static String get forgotPasswordTitle =>
      _t('Mot de passe oublié', 'Forgot password', 'نسيت كلمة المرور');
  static String get forgotPasswordBody =>
      _t('Entrez votre email pour recevoir un mot de passe temporaire.',
          'Enter your email to receive a temporary password.',
          'أدخل بريدك الإلكتروني لاستلام كلمة مرور مؤقتة.');
  static String get send => _t('Envoyer', 'Send', 'إرسال');
  static String get emailSentGeneric =>
      _t('Si ce compte existe, un email a été envoyé.',
          'If this account exists, an email was sent.',
          'إذا كان هذا الحساب موجوداً، فقد تم إرسال بريد إلكتروني.');

  // ── Language names ────────────────────────────────────────────────────────
  static String get langFr => _t('Français', 'French', 'الفرنسية');
  static String get langEn => _t('English', 'English', 'الإنجليزية');
  static String get langAr => _t('Arabe', 'Arabic', 'العربية');
}
