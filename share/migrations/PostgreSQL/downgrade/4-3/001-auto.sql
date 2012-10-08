-- Convert schema '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/4/001-auto.yml' to '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE board_rank DROP CONSTRAINT board_rank_fk_parent_rank_id;

;
ALTER TABLE theme_asset_version DROP CONSTRAINT theme_asset_version_fk_theme_edition_id;

;
DROP INDEX board_rank_idx_parent_rank_id;

;
DROP INDEX theme_asset_version_idx_theme_edition_id;

;
ALTER TABLE board_rank DROP COLUMN parent_rank_id;

;
ALTER TABLE theme_asset_version DROP COLUMN mime_type;

;
ALTER TABLE theme_asset_version DROP COLUMN width;

;
ALTER TABLE theme_asset_version DROP COLUMN heigth;

;
ALTER TABLE theme_asset_version DROP COLUMN file_id;

;
ALTER TABLE theme_asset_version DROP COLUMN theme_edition_id;

;
ALTER TABLE theme_asset_version ADD COLUMN filename character(20) NOT NULL;

;
ALTER TABLE theme_asset_version ALTER COLUMN name SET NOT NULL;

;

COMMIT;

