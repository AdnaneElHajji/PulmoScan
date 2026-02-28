// lib/models/patient.dart
// Ce fichier définit la structure d'un Patient dans l'application

class Patient {
  final int? id;           // ID auto-généré par SQLite (null si pas encore enregistré)
  final String nom;        // Nom complet du patient
  final int age;           // Âge
  final String genre;      // Homme / Femme / Autre
  final String email;      // Email
  final String telephone;  // Téléphone
  final String cin;        // Carte d'identité nationale
  final String antecedents; // Antécédents médicaux
  final DateTime dateCreation; // Date d'ajout du patient

  // Constructeur : crée un objet Patient
  Patient({
    this.id,
    required this.nom,
    required this.age,
    required this.genre,
    required this.email,
    required this.telephone,
    required this.cin,
    required this.antecedents,
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
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}