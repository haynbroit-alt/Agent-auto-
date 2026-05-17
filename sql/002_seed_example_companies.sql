-- Données de démo (à exécuter manuellement après coup : psql ou Adminer)
-- Adapte les secteurs / régions pour tester le scoring du workflow n8n.

INSERT INTO fl_companies (siret, raison_sociale, secteur_naf, effectif, region, metadata)
VALUES
  ('73282932000074', 'DEMO SARL BTP Île-de-France', '43.99C', '11-50', 'Île-de-France', '{"tags":["construction","rénovation"]}'::jsonb),
  ('12345678901234', 'DEMO SAS Logiciel national', '62.01Z', '1-10', 'National', '{"tags":["logiciel","saas","ia"]}'::jsonb)
ON CONFLICT (siret) DO NOTHING;
