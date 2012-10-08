-- Convert schema '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/2/001-auto.yml' to '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE "user" ADD COLUMN experience integer DEFAULT 0 NOT NULL;

;
ALTER TABLE "user" ADD COLUMN spendable_karma integer DEFAULT 0 NOT NULL;

;
ALTER TABLE api_key ALTER COLUMN token TYPE text;

;
ALTER TABLE api_key ALTER COLUMN token_secret TYPE text;

;
ALTER TABLE asset_version ALTER COLUMN name TYPE text;

;
ALTER TABLE asset_version ALTER COLUMN type TYPE text;

;
ALTER TABLE board ALTER COLUMN name TYPE text;

;
ALTER TABLE board_rank ALTER COLUMN name TYPE text;

;
ALTER TABLE edition ALTER COLUMN primary_language TYPE text;

;
ALTER TABLE email ALTER COLUMN email TYPE text;

;
ALTER TABLE library ALTER COLUMN new_project_prefix TYPE text;

;
ALTER TABLE library ALTER COLUMN new_theme_prefix TYPE text;

;
ALTER TABLE library_project_version ALTER COLUMN prefix TYPE text;

;
ALTER TABLE library_theme_version ALTER COLUMN prefix TYPE text;

;
ALTER TABLE oauth_identity ALTER COLUMN oauth_user_id TYPE text;

;
ALTER TABLE oauth_identity ALTER COLUMN screen_name TYPE text;

;
ALTER TABLE oauth_identity ALTER COLUMN token TYPE text;

;
ALTER TABLE oauth_identity ALTER COLUMN token_secret TYPE text;

;
ALTER TABLE oauth_identity ALTER COLUMN profile_img_url TYPE text;

;
ALTER TABLE page_part ALTER COLUMN name TYPE text;

;
ALTER TABLE page_part ALTER COLUMN filter TYPE text;

;
ALTER TABLE page_version ALTER COLUMN slug TYPE text;

;
ALTER TABLE page_version ALTER COLUMN title TYPE text;

;
ALTER TABLE page_version ALTER COLUMN primary_language TYPE text;

;
ALTER TABLE snippet_version ALTER COLUMN name TYPE text;

;
ALTER TABLE snippet_version ALTER COLUMN filter TYPE text;

;
ALTER TABLE theme_asset_version ALTER COLUMN name TYPE text;

;
ALTER TABLE theme_asset_version ALTER COLUMN type TYPE text;

;
ALTER TABLE theme_layout_version ALTER COLUMN name TYPE text;

;
ALTER TABLE theme_snippet_version ALTER COLUMN name TYPE text;

;
ALTER TABLE theme_snippet_version ALTER COLUMN filter TYPE text;

;
ALTER TABLE theme_style_version ALTER COLUMN name TYPE text;

;
ALTER TABLE theme_variable_version ALTER COLUMN name TYPE text;

;
ALTER TABLE theme_variable_version ALTER COLUMN type TYPE text;

;
ALTER TABLE typeface_font_file ALTER COLUMN format TYPE text;

;
ALTER TABLE typeface_font_version ALTER COLUMN weight TYPE text;

;
ALTER TABLE typeface_font_version ALTER COLUMN style TYPE text;

;
ALTER TABLE "user" ALTER COLUMN lang TYPE text;

;
ALTER TABLE "user" ALTER COLUMN name TYPE text;

;
ALTER TABLE "user" ALTER COLUMN url TYPE text;

;
ALTER TABLE "user" ALTER COLUMN timezone TYPE text;

;

COMMIT;

