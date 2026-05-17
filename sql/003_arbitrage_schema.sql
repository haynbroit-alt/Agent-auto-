-- Composer 2 — Arbitrage réglementaire (tables métier FogLifter)
-- S’exécute sur la base `foglifter` (même instance que Composer 1).
-- Sur volume Postgres déjà initialisé : appliquer manuellement avec psql.

CREATE TABLE IF NOT EXISTS fl_regulatory_events (
    id BIGSERIAL PRIMARY KEY,
    source_url TEXT NOT NULL,
    content_hash TEXT NOT NULL,
    title TEXT,
    extracted_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    event_date TIMESTAMPTZ,
    impact_score NUMERIC(8, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (source_url, content_hash)
);

CREATE TABLE IF NOT EXISTS fl_instruments (
    isin TEXT PRIMARY KEY,
    symbol TEXT,
    type TEXT,
    sector TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fl_arbitrage_matches (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL REFERENCES fl_regulatory_events (id) ON DELETE CASCADE,
    instrument_id TEXT NOT NULL REFERENCES fl_instruments (isin) ON DELETE CASCADE,
    signal TEXT NOT NULL,
    confidence NUMERIC(8, 2) NOT NULL DEFAULT 0,
    expected_return NUMERIC(12, 4),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (event_id, instrument_id),
    CONSTRAINT fl_arbitrage_matches_signal_chk CHECK (signal IN ('BUY', 'SELL', 'HOLD'))
);

CREATE INDEX IF NOT EXISTS idx_fl_reg_events_created ON fl_regulatory_events (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fl_reg_events_impact ON fl_regulatory_events (impact_score DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_fl_arb_matches_conf ON fl_arbitrage_matches (confidence DESC);
