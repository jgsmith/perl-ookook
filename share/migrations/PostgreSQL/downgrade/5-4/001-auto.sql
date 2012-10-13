-- Convert schema '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/5/001-auto.yml' to '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/4/001-auto.yml':;

;
BEGIN;

;
DROP INDEX asset_version_idx_published_for;

;
DROP INDEX library_project_version_idx_published_for;

;
DROP INDEX library_theme_version_idx_published_for;

;
DROP INDEX page_version_idx_published_for;

;
DROP INDEX snippet_version_idx_published_for;

;
DROP INDEX theme_asset_version_idx_published_for;

;
DROP INDEX theme_layout_version_idx_published_for;

;
DROP INDEX theme_snippet_version_idx_published_for;

;
DROP INDEX theme_style_version_idx_published_for;

;
DROP INDEX theme_variable_version_idx_published_for;

;
DROP INDEX typeface_font_version_idx_published_for;

;
ALTER TABLE asset DROP CONSTRAINT asset_fk_project_id;

;
ALTER TABLE asset_version DROP CONSTRAINT asset_version_fk_edition_id;

;
DROP INDEX asset_idx_project_id;

;
DROP INDEX asset_version_idx_edition_id;

;
ALTER TABLE asset DROP COLUMN project_id;

;
ALTER TABLE asset_version DROP COLUMN published_for;

;
ALTER TABLE asset_version DROP COLUMN edition_id;

;
ALTER TABLE library_project_version DROP COLUMN published_for;

;
ALTER TABLE library_theme_version DROP COLUMN published_for;

;
ALTER TABLE page_version DROP COLUMN published_for;

;
ALTER TABLE snippet_version DROP COLUMN published_for;

;
ALTER TABLE theme_asset_version DROP COLUMN published_for;

;
ALTER TABLE theme_layout_version DROP COLUMN published_for;

;
ALTER TABLE theme_snippet_version DROP COLUMN published_for;

;
ALTER TABLE theme_style_version DROP COLUMN published_for;

;
ALTER TABLE theme_variable_version DROP COLUMN published_for;

;
ALTER TABLE typeface_font_version DROP COLUMN published_for;

;
ALTER TABLE edition ADD COLUMN closed_on timestamp;

;
ALTER TABLE library_edition ADD COLUMN closed_on timestamp;

;
ALTER TABLE theme_edition ADD COLUMN closed_on timestamp;

;
ALTER TABLE typeface_edition ADD COLUMN closed_on timestamp;

;
ALTER TABLE edition ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE library_edition ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE theme_edition ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE typeface_edition ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE email ADD CONSTRAINT email_email UNIQUE (email);

;
ALTER TABLE typeface_font_file ADD CONSTRAINT typeface_font_file_filename UNIQUE (filename);

;

COMMIT;

