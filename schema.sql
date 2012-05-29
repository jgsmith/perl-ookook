PRAGMA foreign_keys = ON;

--
-- Users
--

CREATE TABLE user (
  id      INTEGER PRIMARY KEY
);

CREATE TABLE user_identity (
  id      INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL
); 

--
-- Projects
--
CREATE TABLE project (
  id      INTEGER PRIMARY KEY,
  uuid    char(20) NOT NULL,
  created_on DATETIME NOT NULL,
  user_id INTEGER
);

CREATE TABLE edition (
  id      INTEGER PRIMARY KEY,
  project_id INTEGER NOT NULL,
  name    VARCHAR(255) NOT NULL DEFAULT '',
  description TEXT,
  sitemap TEXT NOT NULL DEFAULT '{}', -- json-encoded sitemap
  theme_id INTEGER,
  theme_date DATETIME,
  created_on DATETIME NOT NULL,
  frozen_on DATETIME          -- convenience - should be the same as the next
                             -- project instance created_on time
);

-- CREATE TABLE data_store (
--  id         INTEGER PRIMARY KEY,
--  owner_id   INTEGER NOT NULL, -- the object holding this data store
--  owner_type VARCHAR(32),      -- the object type holding this data store
--  name       VARCHAR(64) NOT NULL,
--  description TEXT
--);
--
--CREATE TABLE data_type (
--  id         INTEGER PRIMARY KEY,
--  data_store_id INTEGER,
--  name       VARCHAR(32) NOT NULL
--);
--
--CREATE TABLE data_namespace (
--  id         INTEGER PRIMARY KEY,
--  edition_id INTEGER NOT NULL,
--  prefix     VARCHAR(32) NOT NULL,
--  namespace  VARCHAR(255) NOT NULL
--);
--
--CREATE TABLE data_property (
--  id         INTEGER PRIMARY KEY,
--  data_store_id INTEGER NOT NULL,
--  data_namespace_id INTEGER,
--  name       VARCHAR(64) NOT NULL,
--  type       VARCHAR(32) NOT NULL
--);
--
--CREATE TABLE data_view (
--  id         INTEGER PRIMARY KEY,
--  owner_id   INTEGER NOT NULL, -- the object holding this data store
--  owner_type VARCHAR(32),      -- the object type holding this data store
--  source_id  INTEGER NOT NULL,
--  source_type VARCHAR(16) NOT NULL,
--  name       VARCHAR(64) NOT NULL
--);

--
-- Content pages
--

--
-- we follow a Radiant model of page having page parts and layouts
--

CREATE TABLE layout (
  id    INTEGER PRIMARY KEY,
  edition_id INTEGER NOT NULL,
  theme_layout_uuid CHAR(20) NOT NULL, 
  name  VARCHAR(255) NOT NULL,
  type  VARCHAR(32) NOT NULL, -- visual, data, ...
  configuration TEXT NOT NULL DEFAULT '{}' -- json
);

CREATE TABLE page (
  id    INTEGER PRIMARY KEY,
  edition_id INTEGER NOT NULL,
  uuid  char(20) NOT NULL,
  title  VARCHAR(255) NOT NULL,
  layout VARCHAR(255),
  description TEXT
);

CREATE TABLE page_part (
  id    INTEGER PRIMARY KEY,
  page_id INTEGER NOT NULL,
  name  VARCHAR(64) NOT NULL,
  content TEXT
);



---
--- Themes
---

CREATE TABLE theme (
  id      INTEGER PRIMARY KEY,
  uuid    char(20) NOT NULL,
  user_id INTEGER
);

CREATE TABLE theme_edition (
  id      INTEGER PRIMARY KEY,
  theme_id INTEGER NOT NULL,
  name    VARCHAR(255) NOT NULL,
  description TEXT,
  created_on DATETIME NOT NULL,
  frozen_on DATETIME
);

CREATE TABLE theme_layout (
  id      INTEGER PRIMARY KEY,
  theme_edition_id INTEGER NOT NULL,
  uuid   CHAR(20) NOT NULL,
  name    VARCHAR(255) NOT NULL,
  layout TEXT,
  configuration TEXT
);

CREATE TABLE theme_style (
  id      INTEGER PRIMARY KEY,
  theme_edition_id INTEGER NOT NULL,
  uuid    CHAR(20) NOT NULL,
  name    VARCHAR(255) NOT NULL,
  styles  TEXT
);

---
--- Component
---

--- We need to be able to freeze the API and still maintain the
--- implementation


