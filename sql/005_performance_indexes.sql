-- Index et optimisations lecture-intensive (Composer 1 & 2)
-- Exécuté après 001 et 003 sur initdb ; sur base existante : psql -f sql/005_performance_indexes.sql
-- Ne pas utiliser CREATE INDEX CONCURRENTLY ici (scripts initdb = transaction unique).

CREATE INDEX IF NOT EXISTS idx_fl_companies_secteur ON fl_companies (secteur_naf);
CREATE INDEX IF NOT EXISTS idx_fl_companies_region ON fl_companies (region);
CREATE INDEX IF NOT EXISTS idx_fl_companies_siret ON fl_companies (siret);

CREATE INDEX IF NOT EXISTS idx_fl_matches_subsidy ON fl_matches (subsidy_id);
CREATE INDEX IF NOT EXISTS idx_fl_matches_company ON fl_matches (company_id);
CREATE INDEX IF NOT EXISTS idx_fl_matches_created ON fl_matches (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_fl_action_logs_created ON fl_action_logs (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fl_action_logs_match ON fl_action_logs (match_id);

CREATE INDEX IF NOT EXISTS idx_fl_subsidies_source ON fl_subsidies_raw (source_url);
CREATE INDEX IF NOT EXISTS idx_fl_subsidies_extracted_gin ON fl_subsidies_raw USING gin (extracted_json jsonb_path_ops);

CREATE INDEX IF NOT EXISTS idx_fl_reg_events_source ON fl_regulatory_events (source_url);
CREATE INDEX IF NOT EXISTS idx_fl_reg_events_extracted_gin ON fl_regulatory_events USING gin (extracted_json jsonb_path_ops);

CREATE INDEX IF NOT EXISTS idx_fl_instruments_symbol ON fl_instruments (symbol);
CREATE INDEX IF NOT EXISTS idx_fl_instruments_sector ON fl_instruments (sector);

CREATE INDEX IF NOT EXISTS idx_fl_arb_matches_event ON fl_arbitrage_matches (event_id);
CREATE INDEX IF NOT EXISTS idx_fl_arb_matches_instrument ON fl_arbitrage_matches (instrument_id);
CREATE INDEX IF NOT EXISTS idx_fl_arb_matches_created ON fl_arbitrage_matches (created_at DESC);

ANALYZE fl_companies;
ANALYZE fl_subsidies_raw;
ANALYZE fl_matches;
ANALYZE fl_action_logs;
ANALYZE fl_regulatory_events;
ANALYZE fl_instruments;
ANALYZE fl_arbitrage_matches;
