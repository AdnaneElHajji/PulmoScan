// lib/models/patient.dart
// Ce fichier définit la structure d'un Patient dans l'application

class Patient {
  final int? id;
  final String nom;
  final int age;
  final String genre;
  final String email;
  final String telephone;
  final String cin;
  final String antecedents;
  final DateTime? dateNaissance;
  final DateTime dateCreation;

  Patient({
    this.id,
    required this.nom,
    required this.age,
    required this.genre,
    required this.email,
    required this.telephone,
    required this.cin,
    required this.antecedents,
    this.dateNaissance,
    required this.dateCreation,
  });

  // Convertit le Patient en Map (dictionnaire) pour SQLite
  // SQLite ne comprend pas les objets Dart, seulement les Maps
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'age': age,
      'genre': genre,
      'email': email,
      'telephone': telephone,
      'cin': cin,
      'antecedents': antecedents,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  // Crée un Patient à partir d'une Map SQLite (l'inverse de toMap)
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      nom: map['nom'],
      age: map['age'],
      genre: map['genre'],
      email: map['email'],
      telephone: map['telephone'],
      cin: map['cin'],
      antecedents: map['antecedents'],
      dateCreation: DateTime.parse(map['dateCreation']),
    );
  }

  // Crée un Patient à partir d'une réponse JSON du backend API
  factory Patient.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return Patient(
      id: rawId == null ? null : (rawId is int ? rawId : int.tryParse(rawId.toString())),
      nom: json['nom'] ?? '',
      age: json['age'] is int ? json['age'] : int.tryParse(json['age'].toString()) ?? 0,
      genre: json['genre'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      cin: json['cin'] ?? '',
      antecedents: json['antecedents'] ?? '',
      dateNaissance: json['date_naissance'] != null
          ? DateTime.tryParse(json['date_naissance'].toString())
          : null,
      dateCreation: DateTime.tryParse(
            json['date_creation'] ?? json['dateCreation'] ?? '',
          ) ??
          DateTime.now(),
    );
  }

  // Permet de copier un patient en modifiant certains champs
  // Utile pour la modification
  Patient copyWith({
    int? id,
    String? nom,
    int? age,
    String? genre,
    String? email,
    String? telephone,
    String? cin,
    String? antecedents,
    DateTime? dateNaissance,
    DateTime? dateCreation,
  }) {
    return Patient(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      age: age ?? this.age,
      genre: genre ?? this.genre,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      cin: cin ?? this.cin,
      antecedents: antecedents ?? this.antecedents,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}