-- Migration script — run once on the existing PulmoScan database:
--   psql -U postgres -d PulmoScan -f db/migration.sql

-- 1. Add 'termine' to examens.statut CHECK
ALTER TABLE examens DROP CONSTRAINT IF EXISTS examens_statut_check;
ALTER TABLE examens ADD CONSTRAINT examens_statut_check
  CHECK (statut IN ('en_attente', 'en_cours', 'analyse', 'termine'));

-- 2. Add 'normal', 'moyen', 'urgent' to resultats.severite CHECK
ALTER TABLE resultats DROP CONSTRAINT IF EXISTS resultats_severite_check;
ALTER TABLE resultats ADD CONSTRAINT resultats_severite_check
  CHECK (severite IN ('faible', 'modere', 'severe', 'normal', 'moyen', 'urgent'));

-- 3. Add UNIQUE constraint on patients.cin
--    Skip if existing rows contain duplicate CINs (fix the data first).
ALTER TABLE patients ADD CONSTRAINT patients_cin_unique UNIQUE (cin);

-- 4. Add date_naissance column to patients
ALTER TABLE patients ADD COLUMN IF NOT EXISTS date_naissance DATE;
