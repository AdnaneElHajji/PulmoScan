// lib/services/database_service.dart
// Ce fichier gère toute la base de données SQLite locale
// Il contient le CRUD complet pour Patient, Exam et Result

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient.dart';
import '../models/exam.dart';
import '../models/result.dart';

class DatabaseService {
  // Instance unique (Singleton) — une seule base de données dans toute l'app
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  // Getter qui ouvre la base si elle n'est pas encore ouverte
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialise la base de données SQLite
  Future<Database> _initDatabase() async {
    // Trouve le chemin du dossier de données de l'app
    String path = join(await getDatabasesPath(), 'pulmoscan.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables, // Crée les tables à la première ouverture
    );
  }

  // Crée les 3 tables : patients, examens, resultats
  Future<void> _createTables(Database db, int version) async {
    // Table patients
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        age INTEGER NOT NULL,
        genre TEXT NOT NULL,
        email TEXT NOT NULL,
        telephone TEXT NOT NULL,
        cin TEXT NOT NULL,
        antecedents TEXT NOT NULL,
        dateCreation TEXT NOT NULL
      )
    ''');

    // Table examens (liée aux patients via patientId)
    await db.execute('''
      CREATE TABLE examens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        imagePath TEXT NOT NULL,
        notes TEXT NOT NULL,
        dateExamen TEXT NOT NULL,
        statut TEXT NOT NULL,
        FOREIGN KEY (patientId) REFERENCES patients (id)
      )
    ''');

    // Table resultats (liée aux examens via examId)
    await db.execute('''
      CREATE TABLE resultats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        examId INTEGER NOT NULL,
        diagnostic TEXT NOT NULL,
        confidence REAL NOT NULL,
        severite TEXT NOT NULL,
        details TEXT NOT NULL,
        dateAnalyse TEXT NOT NULL,
        FOREIGN KEY (examId) REFERENCES examens (id)
      )
    ''');
  }

  // ═══════════════════════════════════════════════
  // CRUD PATIENTS
  // ═══════════════════════════════════════════════

  // CREATE — Ajouter un nouveau patient
  // Règle métier : l'email doit être unique
  Future<int> ajouterPatient(Patient patient) async {
    final db = await database;

    // Vérifie si l'email existe déjà (règle métier 1)
    final existant = await db.query(
      'patients',
      where: 'email = ?',
      whereArgs: [patient.email],
    );

    if (existant.isNotEmpty) {
      throw Exception('Un patient avec cet email existe déjà');
    }

    return await db.insert('patients', patient.toMap());
  }

  // READ — Récupérer tous les patients
  Future<List<Patient>> getTousLesPatients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      orderBy: 'dateCreation DESC', // Les plus récents en premier
    );
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  // READ — Récupérer un patient par son ID
  Future<Patient?> getPatientParId(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  // READ — Rechercher des patients par nom
  Future<List<Patient>> rechercherPatients(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'nom LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'nom ASC',
    );
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  // UPDATE — Modifier un patient existant
  Future<int> modifierPatient(Patient patient) async {
    final db = await database;

    // Vérifie que le patient existe
    if (patient.id == null) {
      throw Exception('Impossible de modifier : patient sans ID');
    }

    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  // DELETE — Supprimer un patient (et ses examens + résultats)
  Future<void> supprimerPatient(int id) async {
    final db = await database;

    // Supprime d'abord les résultats liés aux examens du patient
    final examens = await db.query(
      'examens',
      where: 'patientId = ?',
      whereArgs: [id],
    );
    for (var exam in examens) {
      await db.delete(
        'resultats',
        where: 'examId = ?',
        whereArgs: [exam['id']],
      );
    }

    // Supprime les examens du patient
    await db.delete(
      'examens',
      where: 'patientId = ?',
      whereArgs: [id],
    );

    // Supprime le patient
    await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ═══════════════════════════════════════════════
  // CRUD EXAMENS
  // ═══════════════════════════════════════════════

  // CREATE — Ajouter un examen
  // Règle métier : le patient doit exister
  Future<int> ajouterExamen(Exam exam) async {
    final db = await database;

    // Vérifie que le patient existe (règle métier 2)
    final patient = await getPatientParId(exam.patientId);
    if (patient == null) {
      throw Exception('Patient introuvable — impossible de créer l\'examen');
    }

    // Vérifie que l'image est fournie (règle métier 3)
    if (exam.imagePath.isEmpty) {
      throw Exception('Une image radiologique est obligatoire pour créer un examen');
    }

    return await db.insert('examens', exam.toMap());
  }

  // READ — Récupérer tous les examens d'un patient
  Future<List<Exam>> getExamensParPatient(int patientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'examens',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'dateExamen DESC',
    );
    return maps.map((map) => Exam.fromMap(map)).toList();
  }

  // READ — Récupérer les examens récents (pour le dashboard)
  Future<List<Map<String, dynamic>>> getExamensRecents({int limite = 5}) async {
    final db = await database;
    // Jointure entre examens et patients pour avoir le nom du patient
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*, p.nom as patientNom, r.diagnostic, r.confidence, r.severite
      FROM examens e
      JOIN patients p ON e.patientId = p.id
      LEFT JOIN resultats r ON r.examId = e.id
      ORDER BY e.dateExamen DESC
      LIMIT ?
    ''', [limite]);
    return maps;
  }

  // UPDATE — Modifier le statut d'un examen
  Future<void> mettreAJourStatutExamen(int examId, String statut) async {
    final db = await database;
    await db.update(
      'examens',
      {'statut': statut},
      where: 'id = ?',
      whereArgs: [examId],
    );
  }

  // DELETE — Supprimer un examen et son résultat
  Future<void> supprimerExamen(int examId) async {
    final db = await database;

    // Supprime d'abord le résultat lié
    await db.delete(
      'resultats',
      where: 'examId = ?',
      whereArgs: [examId],
    );

    // Puis supprime l'examen
    await db.delete(
      'examens',
      where: 'id = ?',
      whereArgs: [examId],
    );
  }

  // ═══════════════════════════════════════════════
  // CRUD RÉSULTATS
  // ═══════════════════════════════════════════════

  // CREATE — Enregistrer un résultat d'analyse IA
  Future<int> ajouterResultat(Result result) async {
    final db = await database;
    // Met à jour le statut de l'examen à 'termine'
    await mettreAJourStatutExamen(result.examId, 'termine');
    return await db.insert('resultats', result.toMap());
  }

  // READ — Récupérer le résultat d'un examen
  Future<Result?> getResultatParExam(int examId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'resultats',
      where: 'examId = ?',
      whereArgs: [examId],
    );
    if (maps.isEmpty) return null;
    return Result.fromMap(maps.first);
  }

  // ═══════════════════════════════════════════════
  // STATISTIQUES (pour le Dashboard)
  // ═══════════════════════════════════════════════

  Future<Map<String, dynamic>> getStatistiques() async {
    final db = await database;

    // Compte total patients
    final totalPatients = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM patients'),
    ) ?? 0;

    // Compte examens ce mois
    final maintenant = DateTime.now();
    final debutMois = DateTime(maintenant.year, maintenant.month, 1).toIso8601String();
    final examsMois = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM examens WHERE dateExamen >= ?',
        [debutMois],
      ),
    ) ?? 0;

    // Compte détections positives (non normales)
    final detections = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM resultats WHERE severite != ?',
        ['normal'],
      ),
    ) ?? 0;

    return {
      'totalPatients': totalPatients,
      'examsMois': examsMois,
      'detections': detections,
    };
  }
}