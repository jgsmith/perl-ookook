-- Convert schema '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/4/001-auto.yml' to '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/5/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE email DROP CONSTRAINT email_email;

;
ALTER TABLE typeface_font_file DROP CONSTRAINT typeface_font_file_filename;

;
ALTER TABLE edition DROP COLUMN closed_on;

;
ALTER TABLE library_edition DROP COLUMN closed_on;

;
ALTER TABLE theme_edition DROP COLUMN closed_on;

;
ALTER TABLE typeface_edition DROP COLUMN closed_on;

;
ALTER TABLE asset ADD COLUMN project_id integer;

;
ALTER TABLE asset_version ADD COLUMN published_for tsrange;

;
ALTER TABLE asset_version ADD COLUMN edition_id integer;

;
ALTER TABLE library_project_version ADD COLUMN published_for tsrange;

;
ALTER TABLE library_theme_version ADD COLUMN published_for tsrange;

;
ALTER TABLE page_version ADD COLUMN published_for tsrange;

;
ALTER TABLE snippet_version ADD COLUMN published_for tsrange;

;
ALTER TABLE theme_asset_version ADD COLUMN published_for tsrange;

;
ALTER TABLE theme_layout_version ADD COLUMN published_for tsrange;

;
ALTER TABLE theme_snippet_version ADD COLUMN published_for tsrange;

;
ALTER TABLE theme_style_version ADD COLUMN published_for tsrange;

;
ALTER TABLE theme_variable_version ADD COLUMN published_for tsrange;

;
ALTER TABLE typeface_font_version ADD COLUMN published_for tsrange;

;
ALTER TABLE edition ALTER COLUMN name TYPE text;

;
ALTER TABLE library_edition ALTER COLUMN name TYPE text;

;
ALTER TABLE theme_edition ALTER COLUMN name TYPE text;

;
ALTER TABLE typeface_edition ALTER COLUMN name TYPE text;

;
CREATE INDEX asset_idx_project_id on asset (project_id);

;
CREATE INDEX asset_version_idx_edition_id on asset_version (edition_id);

;
ALTER TABLE asset ADD CONSTRAINT asset_fk_project_id FOREIGN KEY (project_id)
  REFERENCES project (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE asset_version ADD CONSTRAINT asset_version_fk_edition_id FOREIGN KEY (edition_id)
  REFERENCES edition (id) ON DELETE CASCADE DEFERRABLE;

;
CREATE INDEX asset_version_idx_published_for on asset_version USING gist (published_for);

;
CREATE INDEX library_project_version_idx_published_for on library_project_version USING gist (published_for);

;
CREATE INDEX library_theme_version_idx_published_for on library_theme_version USING gist (published_for);

;
CREATE INDEX page_version_idx_published_for on page_version USING gist (published_for);

;
CREATE INDEX snippet_version_idx_published_for on snippet_version USING gist (published_for);

;
CREATE INDEX theme_asset_version_idx_published_for on theme_asset_version USING gist (published_for);

;
CREATE INDEX theme_layout_version_idx_published_for on theme_layout_version USING gist (published_for);

;
CREATE INDEX theme_snippet_version_idx_published_for on theme_snippet_version USING gist (published_for);

;
CREATE INDEX theme_style_version_idx_published_for on theme_style_version USING gist (published_for);

;
CREATE INDEX theme_variable_version_idx_published_for on theme_variable_version USING gist (published_for);

;
CREATE INDEX typeface_font_version_idx_published_for on typeface_font_version USING gist (published_for);

;
COMMIT;

