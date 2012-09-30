-- Convert schema '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/2/001-auto.yml' to '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/1/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE library_project DROP CONSTRAINT library_project_fk_project_id;

;
ALTER TABLE library_project_version DROP CONSTRAINT library_project_version_fk_edition_id;

;
DROP INDEX library_project_idx_project_id;

;
DROP INDEX library_project_version_idx_edition_id;

;
ALTER TABLE library_project DROP COLUMN project_id;

;
ALTER TABLE library_project_version DROP COLUMN edition_id;

;

COMMIT;

