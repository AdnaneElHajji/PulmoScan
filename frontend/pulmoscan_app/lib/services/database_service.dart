import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/patient.dart';
import '../models/exam.dart';
import '../models/result.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pulmoscan.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'medecin',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        age INTEGER NOT NULL,
        genre TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        telephone TEXT DEFAULT '',
        cin TEXT NOT NULL UNIQUE,
        antecedents TEXT DEFAULT '',
        date_naissance TEXT,
        date_creation TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS examens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        notes TEXT DEFAULT '',
        date_examen TEXT NOT NULL,
        statut TEXT DEFAULT 'en_attente'
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS resultats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_id INTEGER NOT NULL,
        diagnostic TEXT NOT NULL,
        confidence REAL NOT NULL,
        severite TEXT NOT NULL,
        details TEXT DEFAULT '',
        date_analyse TEXT NOT NULL
      )
    ''');

    // Demo account (password: Demo1234)
    final demoHash = hashPassword('Demo1234');
    await db.insert('users', {
      'name': 'Dr. Kenza Foudali',
      'email': 'demo@pulmoscan.ma',
      'password': demoHash,
      'role': 'medecin',
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // ── AUTH ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final d = await db;
    final hash = hashPassword(password);
    final rows = await d.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, hash]);
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<bool> register(String name, String email, String password,
      {String role = 'medecin'}) async {
    final d = await db;
    final existing =
        await d.query('users', where: 'email = ?', whereArgs: [email]);
    if (existing.isNotEmpty) return false;
    final hash = hashPassword(password);
    await d.insert('users', {
      'name': name,
      'email': email,
      'password': hash,
      'role': role,
      'created_at': DateTime.now().toIso8601String(),
    });
    return true;
  }

  /// Insert or update a user record (used after successful Railway login).
  Future<void> upsertUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final d = await db;
    final hash = hashPassword(password);
    final existing =
        await d.query('users', where: 'email = ?', whereArgs: [email]);
    if (existing.isEmpty) {
      await d.insert('users', {
        'name': name,
        'email': email,
        'password': hash,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await d.update(
        'users',
        {'name': name, 'password': hash, 'role': role},
        where: 'email = ?',
        whereArgs: [email],
      );
    }
  }

  Future<bool> changePassword(
      String email, String oldPassword, String newPassword) async {
    final d = await db;
    final hash = hashPassword(oldPassword);
    final rows = await d.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, hash]);
    if (rows.isEmpty) return false;
    final newHash = hashPassword(newPassword);
    await d.update('users', {'password': newHash},
        where: 'email = ?', whereArgs: [email]);
    return true;
  }

  // ── PATIENTS ───────────────────────────────────────────────────────────────

  Future<List<Patient>> getPatients({String search = ''}) async {
    final d = await db;
    final rows = search.isEmpty
        ? await d.query('patients', orderBy: 'date_creation DESC')
        : await d.query('patients',
            where: 'nom LIKE ? OR email LIKE ?',
            whereArgs: ['%$search%', '%$search%'],
            orderBy: 'date_creation DESC');
    return rows.map(_patientFromRow).toList();
  }

  Future<Patient?> getPatientById(int id) async {
    final d = await db;
    final rows =
        await d.query('patients', where: 'id = ?', whereArgs: [id]);
    return rows.isNotEmpty ? _patientFromRow(rows.first) : null;
  }

  Future<Patient> createPatient(Map<String, dynamic> body) async {
    final d = await db;
    final existing = await d.query('patients',
        where: 'email = ?', whereArgs: [body['email']]);
    if (existing.isNotEmpty) {
      throw Exception('Un patient avec cet email existe déjà');
    }
    final now = DateTime.now().toIso8601String();
    final id = await d.insert('patients', {
      'nom': body['nom'],
      'age': body['age'],
      'genre': body['genre'],
      'email': body['email'],
      'telephone': body['telephone'] ?? '',
      'cin': body['cin'],
      'antecedents': body['antecedents'] ?? '',
      'date_naissance': body['date_naissance'],
      'date_creation': now,
    });
    final rows =
        await d.query('patients', where: 'id = ?', whereArgs: [id]);
    return _patientFromRow(rows.first);
  }

  Future<Patient> updatePatient(int id, Map<String, dynamic> body) async {
    final d = await db;
    final emailTaken = await d.query('patients',
        where: 'email = ? AND id != ?', whereArgs: [body['email'], id]);
    if (emailTaken.isNotEmpty) {
      throw Exception('Cet email est déjà utilisé');
    }
    await d.update(
      'patients',
      {
        'nom': body['nom'],
        'age': body['age'],
        'genre': body['genre'],
        'email': body['email'],
        'telephone': body['telephone'] ?? '',
        'cin': body['cin'],
        'antecedents': body['antecedents'] ?? '',
        'date_naissance': body['date_naissance'],
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    final rows =
        await d.query('patients', where: 'id = ?', whereArgs: [id]);
    return _patientFromRow(rows.first);
  }

  Future<void> deletePatient(int id) async {
    final d = await db;
    // cascade: delete exams and results first
    final exams = await d.query('examens',
        where: 'patient_id = ?', whereArgs: [id]);
    for (final ex in exams) {
      await d.delete('resultats',
          where: 'exam_id = ?', whereArgs: [ex['id']]);
    }
    await d.delete('examens', where: 'patient_id = ?', whereArgs: [id]);
    await d.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // ── EXAMENS ────────────────────────────────────────────────────────────────

  Future<int> createExam(Map<String, dynamic> body) async {
    final d = await db;
    return d.insert('examens', {
      'patient_id': body['patient_id'],
      'image_path': body['image_path'] ?? '',
      'notes': body['notes'] ?? '',
      'date_examen': DateTime.now().toIso8601String(),
      'statut': 'en_cours',
    });
  }

  Future<void> updateExamStatut(int examId, String statut) async {
    final d = await db;
    await d.update('examens', {'statut': statut},
        where: 'id = ?', whereArgs: [examId]);
  }

  Future<List<Map<String, dynamic>>> getAllExamsWithPatient() async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT e.*, p.nom as patient_nom
      FROM examens e
      LEFT JOIN patients p ON e.patient_id = p.id
      ORDER BY e.date_examen DESC
    ''');
    return rows.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  Future<List<Exam>> getExamsByPatient(int patientId) async {
    final d = await db;
    final rows = await d.query('examens',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'date_examen DESC');
    return rows.map(_examFromRow).toList();
  }

  // ── RESULTATS ──────────────────────────────────────────────────────────────

  Future<Result> createResultat(Map<String, dynamic> body) async {
    final d = await db;
    final now = DateTime.now().toIso8601String();
    final id = await d.insert('resultats', {
      'exam_id': body['exam_id'],
      'diagnostic': body['diagnostic'],
      'confidence': body['confidence'],
      'severite': body['severite'],
      'details': body['details'] ?? '',
      'date_analyse': now,
    });
    await updateExamStatut(body['exam_id'] as int, 'termine');
    final rows =
        await d.query('resultats', where: 'id = ?', whereArgs: [id]);
    return _resultatFromRow(rows.first);
  }

  Future<Result?> getResultatByExam(int examId) async {
    final d = await db;
    final rows = await d.query('resultats',
        where: 'exam_id = ?', whereArgs: [examId], limit: 1);
    return rows.isNotEmpty ? _resultatFromRow(rows.first) : null;
  }

  Future<List<Map<String, dynamic>>> getAllResultats() async {
    final d = await db;
    return d.rawQuery('''
      SELECT r.*, e.patient_id, p.nom as patient_nom
      FROM resultats r
      JOIN examens e ON r.exam_id = e.id
      JOIN patients p ON e.patient_id = p.id
      ORDER BY r.date_analyse DESC
    ''');
  }

  // ── STATS ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    final d = await db;
    final patients = Sqflite.firstIntValue(
            await d.rawQuery('SELECT COUNT(*) FROM patients')) ??
        0;
    final examens = Sqflite.firstIntValue(
            await d.rawQuery('SELECT COUNT(*) FROM examens')) ??
        0;
    final resultats = Sqflite.firstIntValue(
            await d.rawQuery('SELECT COUNT(*) FROM resultats')) ??
        0;

    final topRows = await d.rawQuery('''
      SELECT diagnostic, COUNT(*) as total
      FROM resultats
      GROUP BY diagnostic
      ORDER BY total DESC
      LIMIT 5
    ''');
    final statutRows = await d.rawQuery('''
      SELECT statut, COUNT(*) as total
      FROM examens
      GROUP BY statut
    ''');

    return {
      'total_patients': patients,
      'total_examens': examens,
      'total_resultats': resultats,
      'top_diagnostics': topRows
          .map((r) => {
                'diagnostic': r['diagnostic'],
                'total': r['total'],
              })
          .toList(),
      'examens_par_statut': statutRows
          .map((r) => {
                'statut': r['statut'],
                'total': r['total'],
              })
          .toList(),
    };
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────

  Patient _patientFromRow(Map<String, dynamic> r) {
    return Patient(
      id: r['id'] as int,
      nom: r['nom'] as String,
      age: r['age'] as int,
      genre: r['genre'] as String,
      email: r['email'] as String,
      telephone: r['telephone'] as String? ?? '',
      cin: r['cin'] as String,
      antecedents: r['antecedents'] as String? ?? '',
      dateNaissance: r['date_naissance'] != null
          ? DateTime.tryParse(r['date_naissance'] as String)
          : null,
      dateCreation:
          DateTime.tryParse(r['date_creation'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  Exam _examFromRow(Map<String, dynamic> r) {
    return Exam(
      id: r['id'] as int,
      patientId: r['patient_id'] as int,
      imagePath: r['image_path'] as String? ?? '',
      notes: r['notes'] as String? ?? '',
      dateExamen:
          DateTime.tryParse(r['date_examen'] as String? ?? '') ??
              DateTime.now(),
      statut: r['statut'] as String? ?? 'en_attente',
    );
  }

  Result _resultatFromRow(Map<String, dynamic> r) {
    final rawConf = r['confidence'];
    final conf = rawConf is double
        ? rawConf
        : double.tryParse(rawConf.toString()) ?? 0.0;
    // confidence is stored as 0-1, display expects 0-100
    return Result(
      id: r['id'] as int,
      examId: r['exam_id'] as int,
      diagnostic: r['diagnostic'] as String,
      confidence: conf * 100,
      severite: r['severite'] as String,
      details: r['details'] as String? ?? '',
      dateAnalyse:
          DateTime.tryParse(r['date_analyse'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
