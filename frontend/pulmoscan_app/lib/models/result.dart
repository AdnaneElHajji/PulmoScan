// lib/models/result.dart
// Ce fichier définit la structure d'un Résultat d'analyse IA

class Result {
  final int? id;
  final int examId;             // Lien vers l'examen
  final String diagnostic;      // Ex: "Pneumonie détectée"
  final double confidence;      // Score de confiance entre 0 et 100
  final String severite;        // 'normal', 'moyen', 'urgent'
  final String details;         // Détails JSON des résultats IA
  final DateTime dateAnalyse;   // Date de l'analyse

  Result({
    this.id,
    required this.examId,
    required this.diagnostic,
    required this.confidence,
    required this.severite,
    required this.details,
    required this.dateAnalyse,
  });

  // Convertit en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examId': examId,
      'diagnostic': diagnostic,
      'confidence': confidence,
      'severite': severite,
      'details': details,
      'dateAnalyse': dateAnalyse.toIso8601String(),
    };
  }

  // Crée un Result depuis une Map SQLite
  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      id: map['id'],
      examId: map['examId'],
      diagnostic: map['diagnostic'],
      confidence: map['confidence'],
      severite: map['severite'],
      details: map['details'],
      dateAnalyse: DateTime.parse(map['dateAnalyse']),
    );
  }
}