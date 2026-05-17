-- Schéma métier FogLifter (base séparée du schéma n8n)
-- Exécuté au premier démarrage du conteneur foglifter-postgres

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS fl_companies (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    siret           TEXT UNIQUE,
    raison_sociale  TEXT NOT NULL,
    secteur_naf     TEXT,
    effectif        TEXT,
    region          TEXT,
    metadata        JSONB DEFAULT '{}'::jsonb,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fl_subsidies_raw (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_url      TEXT NOT NULL,
    title           TEXT NOT NULL,
    summary         TEXT,
    raw_payload     JSONB DEFAULT '{}'::jsonb,
    extracted_json  JSONB NOT NULL DEFAULT '{}'::jsonb,
    content_hash    TEXT,
    ingested_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (source_url, content_hash)
);

CREATE TABLE IF NOT EXISTS fl_matches (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subsidy_id      UUID NOT NULL REFERENCES fl_subsidies_raw(id) ON DELETE CASCADE,
    company_id      UUID NOT NULL REFERENCES fl_companies(id) ON DELETE CASCADE,
    score           NUMERIC(5,2) NOT NULL DEFAULT 0,
    rationale       TEXT,
    status          TEXT NOT NULL DEFAULT 'candidate',
    commission_pct  NUMERIC(5,2) NOT NULL DEFAULT 15,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (subsidy_id, company_id)
);

CREATE TABLE IF NOT EXISTS fl_action_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id        UUID REFERENCES fl_matches(id) ON DELETE SET NULL,
    action_type     TEXT NOT NULL,
    channel         TEXT,
    payload         JSONB DEFAULT '{}'::jsonb,
    ok              BOOLEAN NOT NULL DEFAULT true,
    error_message   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_fl_matches_score ON fl_matches (score DESC);
CREATE INDEX IF NOT EXISTS idx_fl_subsidies_ingested ON fl_subsidies_raw (ingested_at DESC);
