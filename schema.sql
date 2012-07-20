PRAGMA foreign_keys = ON;
--
-- Users
--

CREATE TABLE user (
  id      INTEGER PRIMARY KEY,
  uuid    CHAR(20) NOT NULL,
  lang    VARCHAR(8),
  name    VARCHAR(255),
  is_admin INTEGER NOT NULL DEFAULT 0, -- will be boolean eventually
  url     VARCHAR(255)
);

INSERT INTO user (id, uuid, lang, name, is_admin) VALUES
                 (1, '*locked*', 'en', 'System Admin', 1);
  

CREATE TABLE oauth_identity (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  oauth_service_id INTEGER, -- defined in the ookook_local.conf file
  oauth_user_id VARCHAR(128), -- internal unique id from service
  screen_name VARCHAR(255), -- public unique id from service
  token VARCHAR(255),
  token_secret VARCHAR(255),
  profile_img_url VARCHAR(255)
);

--
-- api keys are for programattic access to the API when OAuth isn't an
-- option -- these don't grant access to certain things, like profile
-- information
--
CREATE TABLE api_key (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  token VARCHAR(255),
  token_secret VARCHAR(255)
);

--
-- Groups
--

CREATE TABLE board (
  id       INTEGER PRIMARY KEY,
  uuid     CHAR(20),
  name     VARCHAR(255)
);

-- overall admin is the top-rank (position==0)
-- only admin may demote themselves, but we may allow a voting system
--  for promotion/demotion
CREATE TABLE board_rank (
  id       INTEGER PRIMARY KEY,
  board_id INTEGER NOT NULL,
  name     VARCHAR(255),
  position INTEGER NOT NULL, -- lower numbers have higher rank
  is_editor BOOLEAN NOT NULL DEFAULT FALSE
);  

CREATE TABLE board_member (
  id       INTEGER PRIMARY KEY,
  user_id  INTEGER NOT NULL,
  board_rank_id INTEGER NOT NULL
);
 
--
-- Projects
--
CREATE TABLE project (
  id      INTEGER PRIMARY KEY,
  uuid    char(20) NOT NULL,
  board_id INTEGER
);

CREATE TABLE edition (
  id      INTEGER PRIMARY KEY,
  project_id INTEGER NOT NULL,
  page_id INTEGER, -- root page
  primary_language VARCHAR(32) NOT NULL DEFAULT 'en',
  name    VARCHAR(255) NOT NULL DEFAULT '',
  description TEXT,
  sitemap TEXT NOT NULL DEFAULT '{}', -- json-encoded sitemap
  theme_id INTEGER,
  theme_date DATETIME,
  created_on DATETIME NOT NULL,
  closed_on DATETIME          -- convenience - should be the same as the next
                             -- project instance created_on time
);

--
-- Content pages
--

--
-- we follow a Radiant model of page having page parts and layouts
--

-- CREATE TABLE layout (
--   id    INTEGER PRIMARY KEY,
--   edition_id INTEGER NOT NULL,
--   uuid  CHAR(20) NOT NULL,
--   theme_layout_uuid CHAR(20) NOT NULL, 
--   type  VARCHAR(32) NOT NULL, -- visual, data, ...
--   configuration TEXT NOT NULL DEFAULT '{}' -- json
-- );

CREATE TABLE page (
  id    INTEGER PRIMARY KEY,
  project_id INTEGER NOT NULL,
  uuid  char(20) NOT NULL
);

CREATE TABLE page_version (
  id    INTEGER PRIMARY KEY,
  edition_id INTEGER NOT NULL,
  page_id INTEGER NOT NULL,
  layout CHAR(20),
  slug VARCHAR(255) NOT NULL DEFAULT '',
  parent_page_id INTEGER,
  title VARCHAR(255) NOT NULL DEFAULT '',
  primary_language VARCHAR(32),
  description TEXT
);

CREATE TABLE page_part (
  id    INTEGER PRIMARY KEY NOT NULL,
  page_version_id INTEGER NOT NULL,
  name  VARCHAR(64) NOT NULL,
  filter VARCHAR(32) NOT NULL DEFAULT 'HTML',
  content TEXT
);

CREATE TABLE snippet (
  id    INTEGER PRIMARY KEY,
  project_id INTEGER NOT NULL,
  uuid  char(20) NOT NULL
);

CREATE TABLE snippet_version (
  id    INTEGER PRIMARY KEY,
  edition_id INTEGER NOT NULL,
  snippet_id INTEGER NOT NULL,
  name    VARCHAR(255),
  content TEXT
);


---
--- Themes
---

CREATE TABLE theme (
  id      INTEGER PRIMARY KEY,
  uuid    char(20) NOT NULL,
  board_id INTEGER
);

CREATE TABLE theme_edition (
  id      INTEGER PRIMARY KEY,
  theme_id INTEGER NOT NULL,
  name    VARCHAR(255) NOT NULL DEFAULT '',
  description TEXT,
  created_on DATETIME NOT NULL,
  closed_on DATETIME
);

CREATE TABLE theme_layout (
  id      INTEGER PRIMARY KEY,
  theme_id INTEGER NOT NULL,
  uuid   CHAR(20) NOT NULL
);

CREATE TABLE theme_layout_version (
  id      INTEGER PRIMARY KEY,
  theme_layout_id INTEGER NOT NULL,
  theme_edition_id INTEGER NOT NULL,
  name    VARCHAR(255) NOT NULL DEFAULT '',
  parent_layout_id INTEGER,
  layout TEXT NOT NULL DEFAULT '<div><page-part name="body"/></div>',
  configuration TEXT NOT NULL DEFAULT '{}'
);

CREATE TABLE theme_style (
  id      INTEGER PRIMARY KEY,
  theme_id INTEGER NOT NULL,
  uuid    CHAR(20) NOT NULL
);

CREATE TABLE theme_style_version (
  id      INTEGER PRIMARY KEY,
  theme_style_id INTEGER NOT NULL,
  theme_edition_id INTEGER NOT NULL,
  name    VARCHAR(255) NOT NULL,
  styles  TEXT
);

---
--- Component
---

--- We need to be able to freeze the API and still maintain the
--- implementation

---
--- Processes
---

CREATE TABLE library (
  id INTEGER PRIMARY KEY,
  uuid CHAR(20) NOT NULL,
  board_id INTEGER
);

CREATE TABLE library_edition (
  id  INTEGER PRIMARY KEY,
  library_id INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL DEFAULT '',
  description TEXT,
  namespace VARCHAR(255),
  created_on DATETIME NOT NULL,
  closed_on DATETIME
);

CREATE TABLE function (
  id INTEGER PRIMARY KEY,
  library_id INTEGER NOT NULL,
  uuid CHAR(20) NOT NULL
);

CREATE TABLE function_version (
  id INTEGER PRIMARY KEY,
  function_id INTEGER NOT NULL,
  library_edition_id INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL,
  definition TEXT NOT NULL
);

CREATE TABLE function_session (
  id INTEGER PRIMARY KEY,
  function_id INTEGER NOT NULL,
  uuid CHAR(20) NOT NULL,
  request TEXT NOT NULL, -- the request body as JSON
  created_on DATETIME NOT NULL,
  expires_on DATETIME NOT NULL
);

---
--- Triple Store Database
---

CREATE TABLE database (
  id INTEGER PRIMARY KEY,
  uuid CHAR(20) NOT NULL,
  board_id INTEGER
);

CREATE TABLE database_edition (
  id INTEGER PRIMARY KEY,
  database_id INTEGER NOT NULL,
  name VARCHAR(255),
  description TEXT,
  created_on DATETIME NOT NULL,
  closed_on DATETIME
);

CREATE TABLE database_namespace_prefix (
  id INTEGER PRIMARY KEY,
  database_id INTEGER NOT NULL,
  uuid VARCHAR(32) NOT NULL -- uuid is the prefix
);

CREATE TABLE database_namespace_prefix_version (
  id INTEGER PRIMARY KEY,
  database_namespace_prefix_id INTEGER NOT NULL,
  database_edition_id INTEGER NOT NULL,
  database_namespace_id INTEGER NOT NULL
);

CREATE TABLE namespace (
  id INTEGER PRIMARY KEY,
  namespace VARCHAR(255) NOT NULL
);

CREATE TABLE predicate (
  id INTEGER PRIMARY KEY,
  namespace_id INTEGER,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE object (
  id INTEGER PRIMARY KEY,
  identifier VARCHAR(255) NOT NULL
);

CREATE TABLE value (
  id INTEGER PRIMARY KEY,
  value TEXT NOT NULL
);

-- CREATE TABLE database_triple (
--   id INTEGER PRIMARY KEY,
--   database_id INTEGER NOT NULL,
--   object_id INTEGER NOT NULL,
--   predicate_id INTEGER NOT NULL,
--   values TEXT, -- eventually, this will be an array in PostgreSQL
--   created_on DATETIME
-- );

-- CREATE TABLE database_elpirt (
--   id INTEGER PRIMARY KEY,
--   database_id INTEGER NOT NULL,
--   value_id INTEGER NOT NULL,
--   predicate_id INTEGER NOT NULL,
--   objects TEXT, -- eventually, this will be an array in PostgreSQL
--   created_on DATETIME
-- );


