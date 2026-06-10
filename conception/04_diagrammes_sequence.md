# Diagrammes de Séquence — PulmoScan

---

## Séquence 1 — Authentification (Login)

```mermaid
sequenceDiagram
    actor Médecin
    participant UI as Interface Login
    participant API as Serveur Express
    participant DB as PostgreSQL

    Médecin->>UI: Saisit email + mot de passe
    UI->>API: POST /api/login {email, password}
    API->>DB: SELECT * FROM users WHERE email=$1

    alt Utilisateur non trouvé
        DB-->>API: []
        API-->>UI: 401 "Utilisateur non trouvé"
        UI-->>Médecin: Affiche message d'erreur
    else Utilisateur trouvé
        DB-->>API: {id, name, email, password, role}
        API->>API: bcrypt.compare(password, hash)
        alt Mot de passe incorrect
            API-->>UI: 401 "Mot de passe incorrect"
            UI-->>Médecin: Affiche message d'erreur
        else Mot de passe correct
            API->>API: jwt.sign({id, email}, secret, 24h)
            API-->>UI: 200 {token, user}
            UI->>UI: SharedPreferences.setString(token)
            UI->>UI: SharedPreferences.setString(user info)
            UI-->>Médecin: Redirection → Dashboard
        end
    end
```

---

## Séquence 2 — Inscription avec vérification email

```mermaid
sequenceDiagram
    actor Médecin
    participant UI as Interface Inscription
    participant API as Serveur Express
    participant DB as PostgreSQL
    participant EMAIL as Nodemailer

    Médecin->>UI: Saisit email
    UI->>API: POST /api/send-code {email}
    API->>API: Génère code 6 chiffres (valable 10 min)
    API->>EMAIL: sendVerificationEmail(email, code)
    EMAIL-->>Médecin: Reçoit le code par email
    API-->>UI: 200 "Code de vérification envoyé"

    Médecin->>UI: Saisit le code reçu
    UI->>API: POST /api/verify-code {email, code}

    alt Code expiré
        API-->>UI: 400 "Code expiré"
        UI-->>Médecin: Affiche erreur + bouton renvoyer
    else Code incorrect
        API-->>UI: 400 "Code incorrect"
        UI-->>Médecin: Affiche erreur
    else Code valide
        API-->>UI: 200 "Email vérifié"
        UI-->>Médecin: Affiche formulaire nom + mot de passe

        Médecin->>UI: Saisit nom + mot de passe (min 8 car.)
        UI->>API: POST /api/register {name, email, password}
        API->>DB: SELECT id FROM users WHERE email=$1

        alt Email déjà utilisé
            DB-->>API: [existant]
            API-->>UI: 409 "Email déjà utilisé"
            UI-->>Médecin: Affiche erreur
        else Nouveau compte
            DB-->>API: []
            API->>API: bcrypt.hash(password, 10)
            API->>DB: INSERT INTO users (name, email, hash, role)
            DB-->>API: {id, name, email, role}
            API-->>UI: 201 {message, user}
            UI-->>Médecin: Redirection → Login
        end
    end
```

---

## Séquence 3 — Ajouter un patient

```mermaid
sequenceDiagram
    actor Médecin
    participant UI as Écran Ajout Patient
    participant VAL as Middleware Validation
    participant API as Serveur Express
    participant DB as PostgreSQL

    Médecin->>UI: Remplit formulaire patient
    Médecin->>UI: Appuie sur "Enregistrer"
    UI->>VAL: validatePatient() [nom, âge, genre, email, CIN]

    alt Champ manquant ou email invalide ou âge hors 1-149
        VAL-->>UI: 400 "Champ invalide"
        UI-->>Médecin: Affiche erreur de validation
    else Données valides
        VAL->>API: POST /api/patients (+ JWT header)
        API->>DB: SELECT id FROM patients WHERE email=$1

        alt Email déjà utilisé
            DB-->>API: [patient existant]
            API-->>UI: 409 "Un patient avec cet email existe déjà"
            UI-->>Médecin: Affiche erreur email
        else Nouveau patient
            DB-->>API: []
            API->>DB: INSERT INTO patients (nom, age, genre, email, telephone, cin, antecedents)
            DB-->>API: {patient créé}
            API-->>UI: 201 {patient}
            UI-->>Médecin: Retour liste + patient ajouté
        end
    end
```

---

## Séquence 4 — Créer un examen et analyser la radiographie (IA)

```mermaid
sequenceDiagram
    actor Médecin
    participant UI as Écran Examen
    participant API as Serveur Express
    participant DB as PostgreSQL
    participant AI as AiService (DenseNet121)

    Médecin->>UI: Sélectionne patient + image radio
    Médecin->>UI: Appuie sur "Analyser"

    UI->>API: POST /api/exams {patient_id, image_path, statut:"en_cours"}
    API->>DB: SELECT id FROM patients WHERE id=$1
    DB-->>API: patient trouvé
    API->>DB: INSERT INTO examens
    DB-->>API: {examId}
    API-->>UI: 201 {examId}

    UI->>AI: analyser(imageFile)
    Note over AI: Prétraitement image
    AI->>AI: grayscale → center crop → resize 224×224
    AI->>AI: Calcul moyenne pixels (détection inversion)
    AI->>AI: Normalisation [0,1]
    Note over AI: Inférence TFLite
    AI->>AI: DenseNet121.run(input[1,224,224,1])
    AI->>AI: 18 sorties sigmoid → 14 classes NIH14
    Note over AI: Sélection diagnostic
    AI->>AI: ratio = score/seuil par classe
    AI->>AI: bestRatio < 1.0 → "Normal"
    AI->>AI: bestRatio ≥ 1.0 → pathologie détectée
    AI-->>UI: {diagnostic, confidence, severite, details JSON}

    UI->>API: POST /api/results {exam_id, diagnostic, confidence, severite, details}
    API->>DB: INSERT INTO resultats
    DB-->>API: résultat inséré
    API->>DB: UPDATE examens SET statut='termine' WHERE id=$1
    DB-->>API: OK
    API-->>UI: 201 {resultat}

    UI-->>Médecin: Navigation → ResultsScreen
```

---

## Séquence 5 — Consulter l'historique et les résultats

```mermaid
sequenceDiagram
    actor Médecin
    participant HIST as Écran Historique
    participant DET as Écran Détail Patient
    participant RES as Écran Résultats
    participant API as Serveur Express
    participant DB as PostgreSQL

    Médecin->>HIST: Ouvre l'onglet Historique
    HIST->>API: GET /api/results
    API->>DB: SELECT r.*, e.patient_id, p.nom FROM resultats r\n JOIN examens e JOIN patients p ORDER BY date DESC
    DB-->>API: [{examens avec patient_nom}]
    API-->>HIST: liste des examens
    HIST-->>Médecin: Affiche liste (date, patient, diagnostic, sévérité)

    Médecin->>HIST: Appuie sur un examen
    HIST->>DET: push PatientDetailScreen(patientId)
    DET->>API: GET /api/patients/:id
    API->>DB: SELECT * FROM patients WHERE id=$1
    DB-->>API: données patient
    DET->>API: GET /api/exams/patient/:id
    API->>DB: SELECT * FROM examens WHERE patient_id=$1
    DB-->>API: liste examens
    API-->>DET: {patient + examens}
    DET-->>Médecin: Fiche patient + historique examens

    Médecin->>DET: Appuie sur un examen spécifique
    DET->>RES: push ResultsScreen(examId, patient, imagePath)
    RES->>API: GET /api/results/exam/:examId
    API->>DB: SELECT * FROM resultats WHERE exam_id=$1
    DB-->>API: {diagnostic, confidence, severite, details}
    API-->>RES: résultat
    RES-->>Médecin: Affiche diagnostic + jauge + 14 barres pathologies
```

---

## Séquence 6 — Exporter le rapport PDF

```mermaid
sequenceDiagram
    actor Médecin
    participant RES as Écran Résultats (Onglet Rapport)
    participant PDF as PdfService
    participant FS as Système Fichiers
    participant SHARE as Dialogue Partage Android

    Médecin->>RES: Appuie sur "Exporter PDF"
    RES->>RES: setState(_exporting = true)
    RES->>PDF: exportAndShare(patient, result, scores, imagePath)

    PDF->>PDF: Crée document PDF
    PDF->>PDF: Ajoute en-tête PulmoScan + logo
    PDF->>PDF: Ajoute section patient (nom, âge, genre, date)
    PDF->>PDF: Ajoute diagnostic principal + confiance + sévérité
    PDF->>PDF: Ajoute anomalies détectées (seuils par classe)
    PDF->>PDF: Ajoute recommandations médicales
    PDF->>PDF: Ajoute clause de non-responsabilité
    PDF->>FS: Écriture fichier rapport_pulmo.pdf (répertoire temp)
    FS-->>PDF: Chemin fichier créé

    PDF->>SHARE: printing.sharePdf(bytes)
    SHARE-->>Médecin: Dialogue "Partager via..." (Email, WhatsApp, Drive, Imprimer...)
    Médecin->>SHARE: Sélectionne destination

    alt Partage réussi
        SHARE-->>Médecin: PDF transmis
        RES->>RES: setState(_exporting = false)
    else Erreur
        PDF-->>RES: Exception levée
        RES-->>Médecin: Snackbar "Erreur PDF : [message]"
        RES->>RES: setState(_exporting = false)
    end
```
