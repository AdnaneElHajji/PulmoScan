# Diagramme de Classes UML — PulmoScan

```mermaid
classDiagram
    direction TB

    class User {
        +int id
        +String name
        +String email
        +String password
        +String role
        +DateTime created_at
    }

    class Patient {
        +int id
        +String nom
        +int age
        +String genre
        +String email
        +String telephone
        +String cin
        +String antecedents
        +DateTime date_creation
        +fromJson(Map json) Patient
        +toJson() Map
    }

    class Examen {
        +int id
        +int patient_id
        +String image_path
        +String notes
        +DateTime date_examen
        +String statut
    }

    class Resultat {
        +int id
        +int exam_id
        +String diagnostic
        +double confidence
        +String severite
        +String details
        +DateTime date_analyse
        +fromJson(Map json) Resultat
    }

    class AiService {
        -Interpreter _interpreter
        +List~String~ labels
        +Map~String,double~ classThresh
        -int imageSize
        -int _numModelOutputs
        +analyser(File imageFile) Map
        -_chargerModele() void
        -_runInference(Image, bool) List~double~
        +dispose() void
    }

    class ApiService {
        -String _tokenKey
        -String _userNameKey
        -String _userEmailKey
        -String _userRoleKey
        +String baseUrl
        +get(String path) dynamic
        +post(String path, Map body) dynamic
        +put(String path, Map body) dynamic
        +delete(String path) dynamic
        +saveToken(String token) void
        +getToken() String
        +saveUser(Map user) void
        +getUser() Map
        +clearToken() void
        +logout() void
    }

    class PdfService {
        +exportAndShare(Patient, Resultat, List, String) void
    }

    class LocaleProvider {
        -Locale _locale
        +Locale locale
        +load() void
        +setLocale(String code) void
    }

    class ExamScreen {
        -List~Patient~ _patients
        -Patient _selected
        -File _image
        -bool _isAnalyzing
        +_analyse() void
        +_pickGallery() void
        +_pickCamera() void
    }

    class ResultsScreen {
        -Result _result
        -List _scores
        +_load() void
        +_copyReport() void
    }

    class PatientsListScreen {
        -List~Patient~ _patients
        -Timer _debounce
        +_load() void
        +_delete(Patient) void
    }

    %% Relations de données (backend)
    User "1" --> "0..*" Examen : crée
    Patient "1" --> "0..*" Examen : possède
    Examen "1" --> "0..1" Resultat : génère

    %% Relations de services (frontend)
    ExamScreen --> AiService : utilise
    ExamScreen --> ApiService : utilise
    ResultsScreen --> ApiService : utilise
    ResultsScreen --> PdfService : utilise
    PatientsListScreen --> ApiService : utilise

    %% Production
    AiService ..> Resultat : produit
    ApiService ..> Patient : gère
    ApiService ..> Examen : gère
    ApiService ..> Resultat : gère
```

## Correspondance Classes ↔ Base de données

| Classe Dart | Table PostgreSQL | Remarques |
|-------------|-----------------|-----------|
| `Patient` | `patients` | Mapping direct, `fromJson` |
| `Examen` | `examens` | Inclut `patient_nom` via JOIN |
| `Resultat` | `resultats` | `confidence` × 100 en Dart |
| `User` | `users` | Géré côté backend uniquement |
| `AiService` | — | Inférence on-device, pas de table |
| `ApiService` | — | Couche HTTP + SharedPreferences |
