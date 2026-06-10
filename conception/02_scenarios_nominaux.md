# Scénarios Nominaux — PulmoScan

---

## Scénario 1 — Authentification (Login)

| Champ | Détail |
|-------|--------|
| **Titre** | Connexion au système |
| **Acteur** | Médecin |
| **Préconditions** | Le médecin possède un compte enregistré. Le serveur backend est opérationnel. |
| **Postconditions** | Le médecin est connecté. Un jeton JWT est stocké localement. Il est redirigé vers le tableau de bord. |

**Déroulement nominal :**

| Étape | Acteur | Système |
|-------|--------|---------|
| 1 | Le médecin ouvre l'application | L'écran de connexion s'affiche |
| 2 | Le médecin saisit son adresse email et son mot de passe | Les champs sont validés en temps réel |
| 3 | Le médecin appuie sur « Se connecter » | L'application envoie `POST /api/login` |
| 4 | | Le serveur vérifie l'email en base de données |
| 5 | | Le serveur compare le mot de passe avec le hash bcrypt |
| 6 | | Le serveur génère un jeton JWT (24h) et le retourne |
| 7 | | L'application sauvegarde le token dans SharedPreferences |
| 8 | | L'application redirige vers le tableau de bord |

**Exceptions :**
- Email inconnu → message « Utilisateur non trouvé »
- Mot de passe incorrect → message « Mot de passe incorrect »
- Serveur inaccessible → message « Impossible de contacter le serveur »
- Trop de tentatives (> 10 en 15 min) → blocage temporaire (rate limiter)

---

## Scénario 2 — Inscription avec vérification email

| Champ | Détail |
|-------|--------|
| **Titre** | Création d'un nouveau compte médecin |
| **Acteur** | Médecin |
| **Préconditions** | L'email n'est pas encore enregistré dans le système. |
| **Postconditions** | Le compte est créé. Le médecin peut se connecter. |

**Déroulement nominal :**

| Étape | Acteur | Système |
|-------|--------|---------|
| 1 | Le médecin appuie sur « Créer un compte » | L'écran d'inscription s'affiche |
| 2 | Le médecin saisit son email | L'application envoie `POST /api/send-code` |
| 3 | | Le serveur génère un code à 6 chiffres (valable 10 min) |
| 4 | | Le serveur envoie le code par email (nodemailer) |
| 5 | Le médecin saisit le code reçu | L'application envoie `POST /api/verify-code` |
| 6 | | Le serveur valide le code et son expiration |
| 7 | Le médecin remplit : nom, mot de passe | L'application valide (min. 8 caractères) |
| 8 | Le médecin soumet le formulaire | L'application envoie `POST /api/register` |
| 9 | | Le serveur hache le mot de passe (bcrypt) et crée le compte |
| 10 | | L'application redirige vers l'écran de connexion |

**Exceptions :**
- Email déjà utilisé → message « Email déjà utilisé » (HTTP 409)
- Code expiré → message « Code expiré, demandez un nouveau code »
- Code incorrect → message « Code incorrect »

---

## Scénario 3 — Ajouter un patient

| Champ | Détail |
|-------|--------|
| **Titre** | Enregistrement d'un nouveau patient |
| **Acteur** | Médecin |
| **Préconditions** | Le médecin est connecté (JWT valide). |
| **Postconditions** | Le patient est enregistré en base de données et apparaît dans la liste. |

**Déroulement nominal :**

| Étape | Acteur | Système |
|-------|--------|---------|
| 1 | Le médecin appuie sur « + » dans la liste des patients | L'écran d'ajout s'affiche |
| 2 | Le médecin remplit : nom, âge, genre, email, téléphone, CIN, antécédents | Validation en temps réel |
| 3 | Le médecin appuie sur « Enregistrer » | Validation des champs (nom, âge 1-149, format email, CIN) |
| 4 | | L'application envoie `POST /api/patients` avec le jeton JWT |
| 5 | | Le serveur vérifie qu'aucun patient avec cet email n'existe |
| 6 | | Le serveur insère le patient en base de données |
| 7 | | L'application retourne à la liste et affiche le nouveau patient |

**Exceptions :**
- Email déjà utilisé par un autre patient → message « Email déjà utilisé »
- CIN en double → contrainte UNIQUE en base
- Champ obligatoire manquant → message de validation

---

## Scénario 4 — Créer un examen et analyser une radiographie

| Champ | Détail |
|-------|--------|
| **Titre** | Analyse d'une radiographie thoracique par IA |
| **Acteur** | Médecin |
| **Préconditions** | Le médecin est connecté. Au moins un patient existe dans le système. |
| **Postconditions** | L'examen est enregistré avec statut `termine`. Le résultat IA est sauvegardé. L'écran de résultats s'affiche. |

**Déroulement nominal :**

| Étape | Acteur | Système |
|-------|--------|---------|
| 1 | Le médecin appuie sur le bouton « + » (FAB) | L'écran d'examen s'affiche |
| 2 | Le médecin sélectionne un patient dans la liste déroulante | Patient sélectionné |
| 3 | Le médecin appuie sur « Choisir une radiographie » | Dialogue galerie / caméra |
| 4 | Le médecin sélectionne l'image | L'aperçu de la radio s'affiche |
| 5 | Le médecin appuie sur « Analyser » | L'application envoie `POST /api/exams` (statut: `en_cours`) |
| 6 | | Le serveur crée l'examen et retourne l'`examId` |
| 7 | | L'application lance `AiService.analyser(image)` en local |
| 8 | | Prétraitement : niveaux de gris → crop centré → resize 224×224 |
| 9 | | Inférence DenseNet121 : 18 sorties sigmoid |
| 10 | | Sélection du meilleur diagnostic par ratio score/seuil |
| 11 | | L'application envoie `POST /api/results` {diagnostic, confidence, severite, details} |
| 12 | | Le serveur sauvegarde le résultat et met statut examen à `termine` |
| 13 | | L'application affiche l'écran ResultsScreen |

**Exceptions :**
- Aucun patient sélectionné → message d'avertissement
- Aucune image sélectionnée → message d'avertissement
- Image illisible → `AiService` lève une exception
- Serveur inaccessible → message d'erreur

---

## Scénario 5 — Consulter les résultats d'un examen

| Champ | Détail |
|-------|--------|
| **Titre** | Consultation du résultat d'analyse IA |
| **Acteur** | Médecin |
| **Préconditions** | Au moins un examen analysé existe dans le système. |
| **Postconditions** | Le médecin visualise le diagnostic, la confiance, la sévérité et les probabilités des 14 pathologies. |

**Déroulement nominal :**

| Étape | Acteur | Système |
|-------|--------|---------|
| 1 | Le médecin ouvre l'onglet « Historique » | La liste des examens s'affiche |
| 2 | Le médecin appuie sur un examen | Navigation vers `PatientDetailScreen` |
| 3 | | L'application charge les données du patient (`GET /api/patients/:id`) |
| 4 | | L'application charge les examens du patient (`GET /api/exams/patient/:id`) |
| 5 | Le médecin appuie sur « Voir résultats » | Navigation vers `ResultsScreen` |
| 6 | | L'application charge le résultat (`GET /api/results/exam/:examId`) |
| 7 | | Affichage : diagnostic principal, jauge de confiance, sévérité |
| 8 | | Affichage : graphique à barres des 14 pathologies avec seuils |
| 9 | | Affichage : radiographie avec zones d'intérêt colorées |
| 10 | Le médecin bascule sur l'onglet « Rapport » | Affichage : recommandations médicales selon la sévérité |

**Exceptions :**
- Résultat non disponible → message « Résultat non disponible »
- Erreur réseau → écran d'erreur avec bouton retour

---

## Scénario 6 — Exporter le rapport en PDF

| Champ | Détail |
|-------|--------|
| **Titre** | Génération et partage du rapport médical PDF |
| **Acteur** | Médecin |
| **Préconditions** | Le médecin est sur l'écran de résultats d'un examen. |
| **Postconditions** | Un fichier PDF est généré et partagé via l'application choisie par le médecin. |

**Déroulement nominal :**

| Étape | Acteur | Système |
|-------|--------|---------|
| 1 | Le médecin appuie sur « Exporter PDF » | Indicateur de chargement affiché |
| 2 | | `PdfService.exportAndShare()` génère le document |
| 3 | | Le PDF inclut : entête PulmoScan, données patient, diagnostic, confiance, sévérité, anomalies détectées, recommandations, avertissement légal |
| 4 | | Le fichier est écrit dans le répertoire temporaire du téléphone |
| 5 | | Le dialogue de partage système s'ouvre |
| 6 | Le médecin choisit l'application de partage (Email, WhatsApp, Drive…) | Le PDF est transmis à l'application choisie |

**Exceptions :**
- Erreur de génération PDF → snackbar « Erreur PDF : [message] »
- Espace disque insuffisant → exception système
