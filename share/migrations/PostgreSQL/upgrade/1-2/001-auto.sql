-- Convert schema '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/1/001-auto.yml' to '/home/jgsmith/Code/OokOok/share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE library_project ADD COLUMN project_id integer;

;
ALTER TABLE library_project_version ADD COLUMN edition_id integer;

;
CREATE INDEX library_project_idx_project_id on library_project (project_id);

;
CREATE INDEX library_project_version_idx_edition_id on library_project_version (edition_id);

;
ALTER TABLE library_project ADD CONSTRAINT library_project_fk_project_id FOREIGN KEY (project_id)
  REFERENCES project (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE library_project_version ADD CONSTRAINT library_project_version_fk_edition_id FOREIGN KEY (edition_id)
  REFERENCES edition (id) ON DELETE CASCADE DEFERRABLE;

;

COMMIT;

