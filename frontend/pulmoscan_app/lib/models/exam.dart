// lib/models/exam.dart
// Ce fichier définit la structure d'un Examen radiologique

class Exam {
  final int? id;
  final int patientId;       // Lien vers le patient (clé étrangère)
  final String imagePath;    // Chemin de l'image sur le téléphone
  final String notes;        // Notes cliniques du médecin
  final DateTime dateExamen; // Date de l'examen
  final String statut;       // 'en_attente', 'analyse', 'termine'

  Exam({
    this.id,
    required this.patientId,
    required this.imagePath,
    required this.notes,
    required this.dateExamen,
    required this.statut,
  });

  // Convertit en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'imagePath': imagePath,
      'notes': notes,
      'dateExamen': dateExamen.toIso8601String(),
      'statut': statut,
    };
  }

  // Crée un Exam depuis une Map SQLite
  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      patientId: map['patientId'],
      imagePath: map['imagePath'],
      notes: map['notes'],
      dateExamen: DateTime.parse(map['dateExamen']),
      statut: map['statut'],
    );
  }

  // Crée un Exam depuis une réponse JSON du backend API
  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      patientId: json['patient_id'] is int
          ? json['patient_id']
          : int.tryParse(json['patient_id'].toString()) ?? 0,
      imagePath: json['image_path'] ?? '',
      notes: json['notes'] ?? '',
      dateExamen:
          DateTime.tryParse(json['date_examen'] ?? '') ?? DateTime.now(),
      statut: json['statut'] ?? 'en_attente',
    );
  }

  Exam copyWith({
    int? id,
    int? patientId,
    String? imagePath,
    String? notes,
    DateTime? dateExamen,
    String? statut,
  }) {
    return Exam(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      dateExamen: dateExamen ?? this.dateExamen,
      statut: statut ?? this.statut,
    );
  }
}