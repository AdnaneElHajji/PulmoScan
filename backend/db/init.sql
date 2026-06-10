-- Script d'initialisation de la base de données PulmoScan
-- Exécuter une seule fois : psql -U postgres -d PulmoScan -f db/init.sql

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role VARCHAR(20) DEFAULT 'medecin',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS patients (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  age INTEGER NOT NULL CHECK (age > 0 AND age < 150),
  genre VARCHAR(10) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  telephone VARCHAR(20) NOT NULL,
  cin VARCHAR(20) NOT NULL UNIQUE,
  antecedents TEXT NOT NULL,
  date_creation TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS examens (
  id SERIAL PRIMARY KEY,
  patient_id INTEGER NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  image_path TEXT NOT NULL,
  notes TEXT DEFAULT '',
  date_examen TIMESTAMP DEFAULT NOW(),
  statut VARCHAR(20) DEFAULT 'en_attente' CHECK (statut IN ('en_attente', 'en_cours', 'analyse', 'termine'))
);

CREATE TABLE IF NOT EXISTS resultats (
  id SERIAL PRIMARY KEY,
  exam_id INTEGER NOT NULL REFERENCES examens(id) ON DELETE CASCADE,
  diagnostic VARCHAR(100) NOT NULL,
  confidence DECIMAL(5,4) NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
  severite VARCHAR(20) NOT NULL CHECK (severite IN ('faible', 'modere', 'severe', 'normal', 'moyen', 'urgent')),
  details TEXT DEFAULT '',
  date_analyse TIMESTAMP DEFAULT NOW()
);
