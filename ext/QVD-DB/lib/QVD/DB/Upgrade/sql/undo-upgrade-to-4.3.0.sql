UPDATE versions SET version = '4.1.2' WHERE component = 'schema';

ALTER TABLE osfs DROP COLUMN is_application;

ALTER TABLE user_tokens DROP COLUMN multi_use;



