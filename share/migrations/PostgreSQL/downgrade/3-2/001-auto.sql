-- Convert schema '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/3/001-auto.yml' to '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE user DROP COLUMN experience;

;
ALTER TABLE user DROP COLUMN spendable_karma;

;
ALTER TABLE api_key ALTER COLUMN token TYPE character varying(255);

;
ALTER TABLE api_key ALTER COLUMN token_secret TYPE character varying(255);

;
ALTER TABLE asset_version ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE asset_version ALTER COLUMN type TYPE character varying(64);

;
ALTER TABLE board ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE board_rank ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE edition ALTER COLUMN primary_language TYPE character varying(255);

;
ALTER TABLE email ALTER COLUMN email TYPE character varying(255);

;
ALTER TABLE library ALTER COLUMN new_project_prefix TYPE character varying(32);

;
ALTER TABLE library ALTER COLUMN new_theme_prefix TYPE character varying(32);

;
ALTER TABLE library_project_version ALTER COLUMN prefix TYPE character varying(32);

;
ALTER TABLE library_theme_version ALTER COLUMN prefix TYPE character varying(32);

;
ALTER TABLE oauth_identity ALTER COLUMN oauth_user_id TYPE character varying(128);

;
ALTER TABLE oauth_identity ALTER COLUMN screen_name TYPE character varying(255);

;
ALTER TABLE oauth_identity ALTER COLUMN token TYPE character varying(255);

;
ALTER TABLE oauth_identity ALTER COLUMN token_secret TYPE character varying(255);

;
ALTER TABLE oauth_identity ALTER COLUMN profile_img_url TYPE character varying(255);

;
ALTER TABLE page_part ALTER COLUMN name TYPE character varying(64);

;
ALTER TABLE page_part ALTER COLUMN filter TYPE character varying(64);

;
ALTER TABLE page_version ALTER COLUMN slug TYPE character varying(255);

;
ALTER TABLE page_version ALTER COLUMN title TYPE character varying(255);

;
ALTER TABLE page_version ALTER COLUMN primary_language TYPE character varying(32);

;
ALTER TABLE snippet_version ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE snippet_version ALTER COLUMN filter TYPE character varying(64);

;
ALTER TABLE theme_asset_version ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE theme_asset_version ALTER COLUMN type TYPE character varying(64);

;
ALTER TABLE theme_layout_version ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE theme_snippet_version ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE theme_snippet_version ALTER COLUMN filter TYPE character varying(64);

;
ALTER TABLE theme_style_version ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE theme_variable_version ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE theme_variable_version ALTER COLUMN type TYPE character varying(255);

;
ALTER TABLE typeface_font_file ALTER COLUMN format TYPE character varying(16);

;
ALTER TABLE typeface_font_version ALTER COLUMN weight TYPE character varying(32);

;
ALTER TABLE typeface_font_version ALTER COLUMN style TYPE character varying(64);

;
ALTER TABLE user ALTER COLUMN lang TYPE character varying(8);

;
ALTER TABLE user ALTER COLUMN name TYPE character varying(255);

;
ALTER TABLE user ALTER COLUMN url TYPE character varying(255);

;
ALTER TABLE user ALTER COLUMN timezone TYPE character varying(255);

;

COMMIT;

