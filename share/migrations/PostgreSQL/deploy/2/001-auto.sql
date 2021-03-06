-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sun Sep 30 13:11:04 2012
-- 
;
--
-- Table: api_key.
--
CREATE TABLE "api_key" (
  "id" serial NOT NULL,
  "token" character varying(255) NOT NULL,
  "token_secret" character varying(255) NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: asset.
--
CREATE TABLE "asset" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "asset_uuid" UNIQUE ("uuid")
);

;
--
-- Table: board.
--
CREATE TABLE "board" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "name" character varying(255) NOT NULL,
  "auto_induct" boolean DEFAULT '0' NOT NULL,
  "permissions" json DEFAULT '{}' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "board_uuid" UNIQUE ("uuid")
);

;
--
-- Table: user.
--
CREATE TABLE "user" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "lang" character varying(8),
  "name" character varying(255),
  "url" character varying(255),
  "timezone" character varying(255),
  "is_admin" boolean DEFAULT '0' NOT NULL,
  "description" text,
  PRIMARY KEY ("id"),
  CONSTRAINT "user_uuid" UNIQUE ("uuid")
);

;
--
-- Table: asset_version.
--
CREATE TABLE "asset_version" (
  "id" serial NOT NULL,
  "status" integer DEFAULT 0 NOT NULL,
  "size" integer,
  "filename" character(20),
  "name" character varying(255) NOT NULL,
  "type" character varying(64),
  "metadata" text,
  "asset_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "asset_version_idx_asset_id" on "asset_version" ("asset_id");

;
--
-- Table: board_rank.
--
CREATE TABLE "board_rank" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "name" character varying(255) NOT NULL,
  "position" integer NOT NULL,
  "board_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "board_rank_uuid" UNIQUE ("uuid")
);
CREATE INDEX "board_rank_idx_board_id" on "board_rank" ("board_id");

;
--
-- Table: email.
--
CREATE TABLE "email" (
  "id" serial NOT NULL,
  "verified" boolean DEFAULT '0' NOT NULL,
  "email" character varying(255) NOT NULL,
  "user_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "email_email" UNIQUE ("email")
);
CREATE INDEX "email_idx_user_id" on "email" ("user_id");

;
--
-- Table: library.
--
CREATE TABLE "library" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "board_id" integer,
  "is_locked" boolean DEFAULT '0' NOT NULL,
  "new_project_prefix" character varying(32),
  "new_theme_prefix" character varying(32),
  PRIMARY KEY ("id"),
  CONSTRAINT "library_uuid" UNIQUE ("uuid")
);
CREATE INDEX "library_idx_board_id" on "library" ("board_id");

;
--
-- Table: oauth_identity.
--
CREATE TABLE "oauth_identity" (
  "id" serial NOT NULL,
  "oauth_service_id" integer,
  "oauth_user_id" character varying(128),
  "screen_name" character varying(255),
  "token" character varying(255),
  "token_secret" character varying(255),
  "profile_img_url" character varying(255),
  "user_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "oauth_identity_idx_user_id" on "oauth_identity" ("user_id");

;
--
-- Table: project.
--
CREATE TABLE "project" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "board_id" integer,
  "is_locked" boolean DEFAULT '0' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "project_uuid" UNIQUE ("uuid")
);
CREATE INDEX "project_idx_board_id" on "project" ("board_id");

;
--
-- Table: theme.
--
CREATE TABLE "theme" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "board_id" integer,
  "is_locked" boolean DEFAULT '0' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "theme_uuid" UNIQUE ("uuid")
);
CREATE INDEX "theme_idx_board_id" on "theme" ("board_id");

;
--
-- Table: typeface.
--
CREATE TABLE "typeface" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "board_id" integer,
  "is_locked" boolean DEFAULT '0' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "typeface_uuid" UNIQUE ("uuid")
);
CREATE INDEX "typeface_idx_board_id" on "typeface" ("board_id");

;
--
-- Table: board_applicant.
--
CREATE TABLE "board_applicant" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "status" integer DEFAULT 0 NOT NULL,
  "vote_deadline" timestamp,
  "application" text,
  "board_id" integer,
  "user_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "board_applicant_uuid" UNIQUE ("uuid")
);
CREATE INDEX "board_applicant_idx_board_id" on "board_applicant" ("board_id");
CREATE INDEX "board_applicant_idx_user_id" on "board_applicant" ("user_id");

;
--
-- Table: library_edition.
--
CREATE TABLE "library_edition" (
  "id" serial NOT NULL,
  "name" character varying(255) DEFAULT '' NOT NULL,
  "description" text,
  "created_on" timestamp NOT NULL,
  "published_for" tsrange,
  "closed_on" timestamp,
  "library_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "library_edition_idx_library_id" on "library_edition" ("library_id");

;
--
-- Table: page.
--
CREATE TABLE "page" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "project_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "page_uuid" UNIQUE ("uuid")
);
CREATE INDEX "page_idx_project_id" on "page" ("project_id");

;
--
-- Table: snippet.
--
CREATE TABLE "snippet" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "project_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "snippet_uuid" UNIQUE ("uuid")
);
CREATE INDEX "snippet_idx_project_id" on "snippet" ("project_id");

;
--
-- Table: theme_asset.
--
CREATE TABLE "theme_asset" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "theme_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "theme_asset_uuid" UNIQUE ("uuid")
);
CREATE INDEX "theme_asset_idx_theme_id" on "theme_asset" ("theme_id");

;
--
-- Table: theme_edition.
--
CREATE TABLE "theme_edition" (
  "id" serial NOT NULL,
  "name" character varying(255) DEFAULT '' NOT NULL,
  "description" text,
  "created_on" timestamp NOT NULL,
  "published_for" tsrange,
  "closed_on" timestamp,
  "theme_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "theme_edition_idx_theme_id" on "theme_edition" ("theme_id");

;
--
-- Table: theme_layout.
--
CREATE TABLE "theme_layout" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "theme_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "theme_layout_uuid" UNIQUE ("uuid")
);
CREATE INDEX "theme_layout_idx_theme_id" on "theme_layout" ("theme_id");

;
--
-- Table: theme_snippet.
--
CREATE TABLE "theme_snippet" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "theme_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "theme_snippet_uuid" UNIQUE ("uuid")
);
CREATE INDEX "theme_snippet_idx_theme_id" on "theme_snippet" ("theme_id");

;
--
-- Table: theme_style.
--
CREATE TABLE "theme_style" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "theme_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "theme_style_uuid" UNIQUE ("uuid")
);
CREATE INDEX "theme_style_idx_theme_id" on "theme_style" ("theme_id");

;
--
-- Table: theme_variable.
--
CREATE TABLE "theme_variable" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "theme_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "theme_variable_uuid" UNIQUE ("uuid")
);
CREATE INDEX "theme_variable_idx_theme_id" on "theme_variable" ("theme_id");

;
--
-- Table: typeface_edition.
--
CREATE TABLE "typeface_edition" (
  "id" serial NOT NULL,
  "name" character varying(255) DEFAULT '' NOT NULL,
  "description" text,
  "created_on" timestamp NOT NULL,
  "published_for" tsrange,
  "closed_on" timestamp,
  "typeface_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "typeface_edition_idx_typeface_id" on "typeface_edition" ("typeface_id");

;
--
-- Table: typeface_font.
--
CREATE TABLE "typeface_font" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "typeface_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "typeface_font_uuid" UNIQUE ("uuid")
);
CREATE INDEX "typeface_font_idx_typeface_id" on "typeface_font" ("typeface_id");

;
--
-- Table: board_member.
--
CREATE TABLE "board_member" (
  "id" serial NOT NULL,
  "board_rank_id" integer,
  "user_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "board_member_idx_board_rank_id" on "board_member" ("board_rank_id");
CREATE INDEX "board_member_idx_user_id" on "board_member" ("user_id");

;
--
-- Table: library_project.
--
CREATE TABLE "library_project" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "library_id" integer,
  "project_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "library_project_uuid" UNIQUE ("uuid")
);
CREATE INDEX "library_project_idx_library_id" on "library_project" ("library_id");
CREATE INDEX "library_project_idx_project_id" on "library_project" ("project_id");

;
--
-- Table: library_theme.
--
CREATE TABLE "library_theme" (
  "id" serial NOT NULL,
  "uuid" character(20) NOT NULL,
  "library_id" integer,
  "theme_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "library_theme_uuid" UNIQUE ("uuid")
);
CREATE INDEX "library_theme_idx_library_id" on "library_theme" ("library_id");
CREATE INDEX "library_theme_idx_theme_id" on "library_theme" ("theme_id");

;
--
-- Table: theme_asset_version.
--
CREATE TABLE "theme_asset_version" (
  "id" serial NOT NULL,
  "status" integer DEFAULT 0 NOT NULL,
  "size" integer,
  "filename" character(20) NOT NULL,
  "name" character varying(255) NOT NULL,
  "type" character varying(64),
  "theme_asset_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "theme_asset_version_idx_theme_asset_id" on "theme_asset_version" ("theme_asset_id");

;
--
-- Table: theme_variable_version.
--
CREATE TABLE "theme_variable_version" (
  "id" serial NOT NULL,
  "status" integer DEFAULT 0 NOT NULL,
  "unused" boolean DEFAULT '0' NOT NULL,
  "name" character varying(255) DEFAULT '' NOT NULL,
  "type" character varying(255) DEFAULT 'text' NOT NULL,
  "theme_variable_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "theme_variable_version_idx_theme_variable_id" on "theme_variable_version" ("theme_variable_id");

;
--
-- Table: typeface_font_version.
--
CREATE TABLE "typeface_font_version" (
  "id" serial NOT NULL,
  "status" integer DEFAULT 0 NOT NULL,
  "weight" character varying(32) DEFAULT 'normal' NOT NULL,
  "style" character varying(64) DEFAULT 'normal' NOT NULL,
  "typeface_font_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "typeface_font_version_idx_typeface_font_id" on "typeface_font_version" ("typeface_font_id");

;
--
-- Table: edition.
--
CREATE TABLE "edition" (
  "id" serial NOT NULL,
  "name" character varying(255) DEFAULT '' NOT NULL,
  "description" text,
  "created_on" timestamp NOT NULL,
  "published_for" tsrange,
  "closed_on" timestamp,
  "default_status" integer DEFAULT 0 NOT NULL,
  "primary_language" character varying(255) DEFAULT '' NOT NULL,
  "home_page_id" integer,
  "theme_id" integer,
  "theme_date" timestamp,
  "project_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "edition_idx_home_page_id" on "edition" ("home_page_id");
CREATE INDEX "edition_idx_project_id" on "edition" ("project_id");
CREATE INDEX "edition_idx_theme_id" on "edition" ("theme_id");

;
--
-- Table: theme_snippet_version.
--
CREATE TABLE "theme_snippet_version" (
  "id" serial NOT NULL,
  "status" integer DEFAULT 0 NOT NULL,
  "name" character varying(255) DEFAULT '' NOT NULL,
  "content" text DEFAULT '' NOT NULL,
  "filter" character varying(64) DEFAULT 'HTML' NOT NULL,
  "theme_edition_id" integer,
  "theme_snippet_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "theme_snippet_version_idx_theme_edition_id" on "theme_snippet_version" ("theme_edition_id");
CREATE INDEX "theme_snippet_version_idx_theme_snippet_id" on "theme_snippet_version" ("theme_snippet_id");

;
--
-- Table: theme_style_version.
--
CREATE TABLE "theme_style_version" (
  "id" serial NOT NULL,
  "status" integer DEFAULT 0 NOT NULL,
  "name" character varying(255) DEFAULT '' NOT NULL,
  "styles" text DEFAULT '' NOT NULL,
  "theme_edition_id" integer,
  "theme_style_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "theme_style_version_idx_theme_edition_id" on "theme_style_version" ("theme_edition_id");
CREATE INDEX "theme_style_version_idx_theme_style_id" on "theme_style_version" ("theme_style_id");

;
--
-- Table: typeface_font_file.
--
CREATE TABLE "typeface_font_file" (
  "id" serial NOT NULL,
  "filename" character(20) NOT NULL,
  "format" character varying(16) NOT NULL,
  "typeface_font_version_id" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "typeface_font_file_filename" UNIQUE ("filename")
);
CREATE INDEX "typeface_font_file_idx_typeface_font_version_id" on "typeface_font_file" ("typeface_font_version_id");

;
--
-- Table: board_member_applicant.
--
CREATE TABLE "board_member_applicant" (
  "id" serial NOT NULL,
  "vote" integer,
  "comments" text,
  "board_member_id" integer,
  "board_applicant_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "board_member_applicant_idx_board_applicant_id" on "board_member_applicant" ("board_applicant_id");
CREATE INDEX "board_member_applicant_idx_board_member_id" on "board_member_applicant" ("board_member_id");

;
--
-- Table: library_theme_version.
--
CREATE TABLE "library_theme_version" (
  "id" serial NOT NULL,
  "library_date" timestamp NOT NULL,
  "prefix" character varying(32),
  "theme_edition_id" integer,
  "library_theme_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "library_theme_version_idx_theme_edition_id" on "library_theme_version" ("theme_edition_id");
CREATE INDEX "library_theme_version_idx_library_theme_id" on "library_theme_version" ("library_theme_id");

;
--
-- Table: page_version.
--
CREATE TABLE "page_version" (
  "id" serial NOT NULL,
  "status" integer DEFAULT 0 NOT NULL,
  "layout" character(20),
  "slug" character varying(255) DEFAULT '' NOT NULL,
  "parent_page_id" integer,
  "page_id" integer NOT NULL,
  "title" character varying(255) DEFAULT '' NOT NULL,
  "primary_language" character varying(32),
  "description" text,
  "edition_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "page_version_idx_edition_id" on "page_version" ("edition_id");
CREATE INDEX "page_version_idx_page_id" on "page_version" ("page_id");
CREATE INDEX "page_version_idx_parent_page_id" on "page_version" ("parent_page_id");

;
--
-- Table: theme_layout_version.
--
CREATE TABLE "theme_layout_version" (
  "id" serial NOT NULL,
  "status" integer DEFAULT 0 NOT NULL,
  "parent_layout_id" integer,
  "theme_layout_id" integer NOT NULL,
  "theme_style_id" integer,
  "internal_layout" boolean DEFAULT '0' NOT NULL,
  "name" character varying(255) DEFAULT '' NOT NULL,
  "layout" text DEFAULT '' NOT NULL,
  "theme_edition_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "theme_layout_version_idx_theme_edition_id" on "theme_layout_version" ("theme_edition_id");
CREATE INDEX "theme_layout_version_idx_parent_layout_id" on "theme_layout_version" ("parent_layout_id");
CREATE INDEX "theme_layout_version_idx_theme_layout_id" on "theme_layout_version" ("theme_layout_id");
CREATE INDEX "theme_layout_version_idx_theme_style_id" on "theme_layout_version" ("theme_style_id");

;
--
-- Table: page_part.
--
CREATE TABLE "page_part" (
  "id" serial NOT NULL,
  "name" character varying(64) NOT NULL,
  "filter" character varying(64) DEFAULT 'HTML' NOT NULL,
  "content" text,
  "page_version_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "page_part_idx_page_version_id" on "page_part" ("page_version_id");

;
--
-- Table: snippet_version.
--
CREATE TABLE "snippet_version" (
  "id" serial NOT NULL,
  "status" integer DEFAULT 0 NOT NULL,
  "name" character varying(255) DEFAULT 'unnamed' NOT NULL,
  "content" text,
  "filter" character varying(64) DEFAULT 'HTML' NOT NULL,
  "snippet_id" integer NOT NULL,
  "edition_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "snippet_version_idx_edition_id" on "snippet_version" ("edition_id");
CREATE INDEX "snippet_version_idx_snippet_id" on "snippet_version" ("snippet_id");

;
--
-- Table: attachment.
--
CREATE TABLE "attachment" (
  "id" serial NOT NULL,
  "asset_id" integer,
  "page_version_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "attachment_idx_asset_id" on "attachment" ("asset_id");
CREATE INDEX "attachment_idx_page_version_id" on "attachment" ("page_version_id");

;
--
-- Table: library_project_version.
--
CREATE TABLE "library_project_version" (
  "id" serial NOT NULL,
  "library_date" timestamp NOT NULL,
  "prefix" character varying(32),
  "library_project_id" integer NOT NULL,
  "edition_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "library_project_version_idx_edition_id" on "library_project_version" ("edition_id");
CREATE INDEX "library_project_version_idx_library_project_id" on "library_project_version" ("library_project_id");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "asset_version" ADD CONSTRAINT "asset_version_fk_asset_id" FOREIGN KEY ("asset_id")
  REFERENCES "asset" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "board_rank" ADD CONSTRAINT "board_rank_fk_board_id" FOREIGN KEY ("board_id")
  REFERENCES "board" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "email" ADD CONSTRAINT "email_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "library" ADD CONSTRAINT "library_fk_board_id" FOREIGN KEY ("board_id")
  REFERENCES "board" ("id") DEFERRABLE;

;
ALTER TABLE "oauth_identity" ADD CONSTRAINT "oauth_identity_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "project" ADD CONSTRAINT "project_fk_board_id" FOREIGN KEY ("board_id")
  REFERENCES "board" ("id") DEFERRABLE;

;
ALTER TABLE "theme" ADD CONSTRAINT "theme_fk_board_id" FOREIGN KEY ("board_id")
  REFERENCES "board" ("id") DEFERRABLE;

;
ALTER TABLE "typeface" ADD CONSTRAINT "typeface_fk_board_id" FOREIGN KEY ("board_id")
  REFERENCES "board" ("id") DEFERRABLE;

;
ALTER TABLE "board_applicant" ADD CONSTRAINT "board_applicant_fk_board_id" FOREIGN KEY ("board_id")
  REFERENCES "board" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "board_applicant" ADD CONSTRAINT "board_applicant_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "library_edition" ADD CONSTRAINT "library_edition_fk_library_id" FOREIGN KEY ("library_id")
  REFERENCES "library" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "page" ADD CONSTRAINT "page_fk_project_id" FOREIGN KEY ("project_id")
  REFERENCES "project" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "snippet" ADD CONSTRAINT "snippet_fk_project_id" FOREIGN KEY ("project_id")
  REFERENCES "project" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_asset" ADD CONSTRAINT "theme_asset_fk_theme_id" FOREIGN KEY ("theme_id")
  REFERENCES "theme" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_edition" ADD CONSTRAINT "theme_edition_fk_theme_id" FOREIGN KEY ("theme_id")
  REFERENCES "theme" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_layout" ADD CONSTRAINT "theme_layout_fk_theme_id" FOREIGN KEY ("theme_id")
  REFERENCES "theme" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_snippet" ADD CONSTRAINT "theme_snippet_fk_theme_id" FOREIGN KEY ("theme_id")
  REFERENCES "theme" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_style" ADD CONSTRAINT "theme_style_fk_theme_id" FOREIGN KEY ("theme_id")
  REFERENCES "theme" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_variable" ADD CONSTRAINT "theme_variable_fk_theme_id" FOREIGN KEY ("theme_id")
  REFERENCES "theme" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "typeface_edition" ADD CONSTRAINT "typeface_edition_fk_typeface_id" FOREIGN KEY ("typeface_id")
  REFERENCES "typeface" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "typeface_font" ADD CONSTRAINT "typeface_font_fk_typeface_id" FOREIGN KEY ("typeface_id")
  REFERENCES "typeface" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "board_member" ADD CONSTRAINT "board_member_fk_board_rank_id" FOREIGN KEY ("board_rank_id")
  REFERENCES "board_rank" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "board_member" ADD CONSTRAINT "board_member_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "library_project" ADD CONSTRAINT "library_project_fk_library_id" FOREIGN KEY ("library_id")
  REFERENCES "library" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "library_project" ADD CONSTRAINT "library_project_fk_project_id" FOREIGN KEY ("project_id")
  REFERENCES "project" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "library_theme" ADD CONSTRAINT "library_theme_fk_library_id" FOREIGN KEY ("library_id")
  REFERENCES "library" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "library_theme" ADD CONSTRAINT "library_theme_fk_theme_id" FOREIGN KEY ("theme_id")
  REFERENCES "theme" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_asset_version" ADD CONSTRAINT "theme_asset_version_fk_theme_asset_id" FOREIGN KEY ("theme_asset_id")
  REFERENCES "theme_asset" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_variable_version" ADD CONSTRAINT "theme_variable_version_fk_theme_variable_id" FOREIGN KEY ("theme_variable_id")
  REFERENCES "theme_variable" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "typeface_font_version" ADD CONSTRAINT "typeface_font_version_fk_typeface_font_id" FOREIGN KEY ("typeface_font_id")
  REFERENCES "typeface_font" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "edition" ADD CONSTRAINT "edition_fk_home_page_id" FOREIGN KEY ("home_page_id")
  REFERENCES "page" ("id") DEFERRABLE;

;
ALTER TABLE "edition" ADD CONSTRAINT "edition_fk_project_id" FOREIGN KEY ("project_id")
  REFERENCES "project" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "edition" ADD CONSTRAINT "edition_fk_theme_id" FOREIGN KEY ("theme_id")
  REFERENCES "theme" ("id") DEFERRABLE;

;
ALTER TABLE "theme_snippet_version" ADD CONSTRAINT "theme_snippet_version_fk_theme_edition_id" FOREIGN KEY ("theme_edition_id")
  REFERENCES "theme_edition" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_snippet_version" ADD CONSTRAINT "theme_snippet_version_fk_theme_snippet_id" FOREIGN KEY ("theme_snippet_id")
  REFERENCES "theme_snippet" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_style_version" ADD CONSTRAINT "theme_style_version_fk_theme_edition_id" FOREIGN KEY ("theme_edition_id")
  REFERENCES "theme_edition" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_style_version" ADD CONSTRAINT "theme_style_version_fk_theme_style_id" FOREIGN KEY ("theme_style_id")
  REFERENCES "theme_style" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "typeface_font_file" ADD CONSTRAINT "typeface_font_file_fk_typeface_font_version_id" FOREIGN KEY ("typeface_font_version_id")
  REFERENCES "typeface_font_version" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "board_member_applicant" ADD CONSTRAINT "board_member_applicant_fk_board_applicant_id" FOREIGN KEY ("board_applicant_id")
  REFERENCES "board_applicant" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "board_member_applicant" ADD CONSTRAINT "board_member_applicant_fk_board_member_id" FOREIGN KEY ("board_member_id")
  REFERENCES "board_member" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "library_theme_version" ADD CONSTRAINT "library_theme_version_fk_theme_edition_id" FOREIGN KEY ("theme_edition_id")
  REFERENCES "theme_edition" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "library_theme_version" ADD CONSTRAINT "library_theme_version_fk_library_theme_id" FOREIGN KEY ("library_theme_id")
  REFERENCES "library_theme" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "page_version" ADD CONSTRAINT "page_version_fk_edition_id" FOREIGN KEY ("edition_id")
  REFERENCES "edition" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "page_version" ADD CONSTRAINT "page_version_fk_page_id" FOREIGN KEY ("page_id")
  REFERENCES "page" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "page_version" ADD CONSTRAINT "page_version_fk_parent_page_id" FOREIGN KEY ("parent_page_id")
  REFERENCES "page" ("id") DEFERRABLE;

;
ALTER TABLE "theme_layout_version" ADD CONSTRAINT "theme_layout_version_fk_theme_edition_id" FOREIGN KEY ("theme_edition_id")
  REFERENCES "theme_edition" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_layout_version" ADD CONSTRAINT "theme_layout_version_fk_parent_layout_id" FOREIGN KEY ("parent_layout_id")
  REFERENCES "theme_layout" ("id") DEFERRABLE;

;
ALTER TABLE "theme_layout_version" ADD CONSTRAINT "theme_layout_version_fk_theme_layout_id" FOREIGN KEY ("theme_layout_id")
  REFERENCES "theme_layout" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "theme_layout_version" ADD CONSTRAINT "theme_layout_version_fk_theme_style_id" FOREIGN KEY ("theme_style_id")
  REFERENCES "theme_style" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "page_part" ADD CONSTRAINT "page_part_fk_page_version_id" FOREIGN KEY ("page_version_id")
  REFERENCES "page_version" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "snippet_version" ADD CONSTRAINT "snippet_version_fk_edition_id" FOREIGN KEY ("edition_id")
  REFERENCES "edition" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "snippet_version" ADD CONSTRAINT "snippet_version_fk_snippet_id" FOREIGN KEY ("snippet_id")
  REFERENCES "snippet" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "attachment" ADD CONSTRAINT "attachment_fk_asset_id" FOREIGN KEY ("asset_id")
  REFERENCES "asset" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "attachment" ADD CONSTRAINT "attachment_fk_page_version_id" FOREIGN KEY ("page_version_id")
  REFERENCES "page_version" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "library_project_version" ADD CONSTRAINT "library_project_version_fk_edition_id" FOREIGN KEY ("edition_id")
  REFERENCES "edition" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "library_project_version" ADD CONSTRAINT "library_project_version_fk_library_project_id" FOREIGN KEY ("library_project_id")
  REFERENCES "library_project" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

