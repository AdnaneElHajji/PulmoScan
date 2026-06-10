# Diagramme de Collaboration — PulmoScan
## Fonctionnalité : Analyse IA d'une radiographie thoracique

```mermaid
graph TB
    M((👨‍⚕️\nMédecin))
    UI[📱 ExamScreen\nInterface Flutter]
    AI[🧠 AiService\nDenseNet121 TFLite]
    ASSETS[📦 Assets Bundle\npulmoscan_model.tflite]
    API[🖥️ Serveur Express\nNode.js]
    DB[(🗄️ PostgreSQL\nBase de données)]

    M -->|"1: choisit patient + image"| UI
    UI -->|"2: POST /api/exams\n{patient_id, image_path, statut:'en_cours'}"| API
    API -->|"3: INSERT INTO examens"| DB
    DB -->|"4: {examId}"| API
    API -->|"5: 201 {examId}"| UI

    UI -->|"6: analyser(imageFile)"| AI
    AI -->|"7: rootBundle.load(model)"| ASSETS
    ASSETS -->|"8: bytes du modèle"| AI
    AI -->|"9: preprocessing\n(grayscale, crop, resize, normalize)"| AI
    AI -->|"10: inference TFLite\n[1,224,224,1] → 18 sigmoid"| AI
    AI -->|"11: seuils par classe\n→ {diagnostic, confidence, severite, details}"| UI

    UI -->|"12: POST /api/results\n{exam_id, diagnostic, confidence, severite, details}"| API
    API -->|"13: INSERT INTO resultats"| DB
    API -->|"14: UPDATE examens\nSET statut='termine'"| DB
    DB -->|"15: confirmation"| API
    API -->|"16: 201 {resultat}"| UI
    UI -->|"17: Navigation ResultsScreen"| M

    style M    fill:#0A0E1A,stroke:#34E5C5,color:#34E5C5
    style UI   fill:#1a2744,stroke:#5A9BFF,color:#fff
    style AI   fill:#1a2744,stroke:#F59E0B,color:#fff
    style ASSETS fill:#1a2744,stroke:#A78BFA,color:#fff
    style API  fill:#1a2744,stroke:#34D399,color:#fff
    style DB   fill:#1a2744,stroke:#F87171,color:#fff
```

## Description des messages

| N° | Émetteur | Récepteur | Message | Type |
|----|----------|-----------|---------|------|
| 1 | Médecin | ExamScreen | Sélection patient + image | Interaction UI |
| 2 | ExamScreen | Serveur API | `POST /api/exams` | HTTP + JWT |
| 3 | Serveur API | PostgreSQL | `INSERT INTO examens` | SQL |
| 4 | PostgreSQL | Serveur API | `examId` retourné | SQL Result |
| 5 | Serveur API | ExamScreen | `201 {examId}` | HTTP Response |
| 6 | ExamScreen | AiService | `analyser(imageFile)` | Appel méthode Dart |
| 7 | AiService | Assets Bundle | Chargement modèle `.tflite` | Lecture fichier |
| 8 | Assets Bundle | AiService | Bytes du modèle | Données binaires |
| 9 | AiService | AiService | Prétraitement image | Traitement interne |
| 10 | AiService | AiService | Inférence TFLite | Calcul neuronal |
| 11 | AiService | ExamScreen | `{diagnostic, confidence, severite, details}` | Retour méthode |
| 12 | ExamScreen | Serveur API | `POST /api/results` | HTTP + JWT |
| 13 | Serveur API | PostgreSQL | `INSERT INTO resultats` | SQL |
| 14 | Serveur API | PostgreSQL | `UPDATE examens SET statut='termine'` | SQL |
| 15 | PostgreSQL | Serveur API | Confirmation | SQL Result |
| 16 | Serveur API | ExamScreen | `201 {resultat}` | HTTP Response |
| 17 | ExamScreen | Médecin | Affichage ResultsScreen | Navigation Flutter |

## Objets participants

| Objet | Type | Rôle |
|-------|------|------|
| Médecin | Acteur | Déclenche l'analyse |
| ExamScreen | Widget Flutter | Orchestre le flux complet |
| AiService | Service Dart (singleton) | Inférence IA on-device |
| Assets Bundle | Ressource Flutter | Contient le modèle TFLite (13.4 MB) |
| Serveur Express | Backend Node.js | API REST + validation + persistance |
| PostgreSQL | SGBD | Stockage examens et résultats |
