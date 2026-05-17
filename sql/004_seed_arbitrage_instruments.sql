-- Jeu minimal pour tester le matching Composer 2 (à exécuter après 003).
-- Les ISIN ci-dessous sont des exemples courants ; adapte selon ton univers d’instruments.

INSERT INTO fl_instruments (isin, symbol, type, sector, metadata)
VALUES
  ('FR0000120271', 'TTE', 'large_cap', 'Énergie', '{"venue":"Euronext"}'::jsonb),
  ('FR0000133308', 'OR', 'large_cap', 'Luxe', '{"venue":"Euronext"}'::jsonb),
  ('US5949181045', 'MSFT', 'large_cap', 'Technologie', '{"venue":"NASDAQ"}'::jsonb)
ON CONFLICT (isin) DO UPDATE SET
  symbol = EXCLUDED.symbol,
  type = EXCLUDED.type,
  sector = EXCLUDED.sector,
  metadata = EXCLUDED.metadata,
  updated_at = now();
