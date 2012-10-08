-- Convert schema '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/3/001-auto.yml' to '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/4/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE theme_asset_version DROP COLUMN filename;

;
ALTER TABLE board_rank ADD COLUMN parent_rank_id integer;

;
ALTER TABLE theme_asset_version ADD COLUMN mime_type text;

;
ALTER TABLE theme_asset_version ADD COLUMN width integer;

;
ALTER TABLE theme_asset_version ADD COLUMN heigth integer;

;
ALTER TABLE theme_asset_version ADD COLUMN file_id text;

;
ALTER TABLE theme_asset_version ADD COLUMN theme_edition_id integer;

;
ALTER TABLE theme_asset_version ALTER COLUMN name DROP NOT NULL;

;
CREATE INDEX board_rank_idx_parent_rank_id on board_rank (parent_rank_id);

;
CREATE INDEX theme_asset_version_idx_theme_edition_id on theme_asset_version (theme_edition_id);

;
ALTER TABLE board_rank ADD CONSTRAINT board_rank_fk_parent_rank_id FOREIGN KEY (parent_rank_id)
  REFERENCES board_rank (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE theme_asset_version ADD CONSTRAINT theme_asset_version_fk_theme_edition_id FOREIGN KEY (theme_edition_id)
  REFERENCES theme_edition (id) ON DELETE CASCADE DEFERRABLE;

;

COMMIT;

