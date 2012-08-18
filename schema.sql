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
  url     VARCHAR(255),
  timezone VARCHAR(255),
  description TEXT
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

CREATE TABLE email (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  verified BOOLEAN NOT NULL DEFAULT 0,
  email VARCHAR(255) NOT NULL
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
  name     VARCHAR(255),
  auto_induct BOOLEAN NOT NULL DEFAULT 0 -- bring in at lowest rank if vote succeeds by deadline
);

-- overall admin is the top-rank (position==0)
-- only admin may demote themselves, but we may allow a voting system
--  for promotion/demotion
CREATE TABLE board_rank (
  id       INTEGER PRIMARY KEY,
  board_id INTEGER NOT NULL,
  name     VARCHAR(255),
  position INTEGER NOT NULL, -- lower numbers have higher rank
    -- we really need permissions to be explicit here so we can search
    -- for people with a particular permission
    -- rank 0 always has all permissions
  may_vote_on_induction BOOLEAN NOT NULL DEFAULT 0,
  permissions TEXT
);

CREATE TABLE board_member (
  id       INTEGER PRIMARY KEY,
  user_id  INTEGER NOT NULL,
  board_id INTEGER NOT NULL,
  rank     INTEGER NOT NULL DEFAULT 0
);
 
CREATE TABLE board_applicant (
  id       INTEGER PRIMARY KEY,
  uuid     CHAR(20),
  user_id  INTEGER NOT NULL,
  board_id INTEGER NOT NULL,
  status   INTEGER NOT NULL DEFAULT 0,
  vote_deadline DATETIME, -- non-null means open for voting
  application TEXT -- arbitrary Q&A
);

CREATE TABLE board_member_applicant (
  id INTEGER PRIMARY KEY,
  board_member_id INTEGER NOT NULL,
  board_applicant_id INTEGER NOT NULL,
  vote INTEGER, -- 1 for in, -1 for out, 0 for abstain, null for undecided
  comments TEXT -- only seen by ranks with permission to see comments/votes
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
  default_status INTEGER NOT NULL DEFAULT 0,
  theme_id INTEGER,
  theme_date DATETIME,
  created_on DATETIME NOT NULL,
  closed_on DATETIME,          -- convenience - should be the same as the next
                             -- project instance created_on time
  primary_language VARCHAR(32) NOT NULL DEFAULT 'en',
  name    VARCHAR(255) NOT NULL DEFAULT '',
  description TEXT
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
  status INTEGER NOT NULL DEFAULT 0, -- published?
  description TEXT
);

CREATE TABLE page_part (
  id    INTEGER PRIMARY KEY NOT NULL,
  page_version_id INTEGER NOT NULL,
  name  VARCHAR(64) NOT NULL,
  filter VARCHAR(32) NOT NULL DEFAULT 'HTML',
  content TEXT
);

-- page_part.name should be unique on page_part.page_version_id

CREATE TABLE snippet (
  id    INTEGER PRIMARY KEY,
  project_id INTEGER NOT NULL,
  uuid  char(20) NOT NULL
);

CREATE TABLE snippet_version (
  id    INTEGER PRIMARY KEY,
  edition_id INTEGER NOT NULL,
  snippet_id INTEGER NOT NULL,
  status INTEGER NOT NULL DEFAULT 0, -- published?
  name    VARCHAR(255),
  content TEXT
);

CREATE TABLE asset (
  id INTEGER PRIMARY KEY,
  project_id INTEGER NOT NULL,
  uuid CHAR(20) NOT NULL
);

CREATE TABLE asset_version (
  id INTEGER PRIMARY KEY,
  edition_id INTEGER NOT NULL,
  asset_id INTEGER NOT NULL,
  status INTEGER NOT NULL DEFAULT 0, -- published?
  size INTEGER,
  filename CHAR(20), -- uuid-like filename for this version
  name VARCHAR(255) NOT NULL,
  type VARCHAR(64), -- the mime type
  metadata TEXT -- arbitrary metadata such as dublin core
);

---
--- Typefaces
---

-- We want to track different font resources that can be used in themes
--
CREATE TABLE typeface (
  id INTEGER PRIMARY KEY,
  uuid char(20) NOT NULL,
  board_id INTEGER
);

CREATE TABLE typeface_edition (
  id INTEGER PRIMARY KEY,
  typeface_id INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL DEFAULT '',
  description TEXT,
  created_on DATETIME NOT NULL,
  closed_on DATETIME
);

CREATE TABLE typeface_font (
  id INTEGER PRIMARY KEY,
  typeface_id INTEGER NOT NULL,
  uuid CHAR(20) NOT NULL
);

CREATE TABLE typeface_font_version (
  id INTEGER PRIMARY KEY,
  typeface_font_id INTEGER NOT NULL,
  typeface_edition_id INTEGER NOT NULL,
  status INTEGER NOT NULL DEFAULT 0, -- published?
  weight VARCHAR(255) NOT NULL DEFAULT 'normal',
  style VARCHAR(255) NOT NULL DEFAULT 'normal'
);

-- we'll want to place these in the filesystem somewhere
-- perhaps something like
--   /typefaces/{typeface-uuid}/{format}/{filename}
-- with filename being a uuid-like string
-- we'll generate a new filename each time we upload something
--
-- we'll need to do some hashing, perhaps, on uuid and filename
--   

CREATE TABLE typeface_font_file (
  id INTEGER PRIMARY KEY,
  typeface_font_version_id INTEGER NOT NULL,
  filename CHAR(20) NOT NULL,
  format VARCHAR(16) NOT NULL
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

CREATE TABLE theme_variable (
  id      INTEGER PRIMARY KEY,
  theme_id INTEGER NOT NULL,
  uuid   CHAR(20) NOT NULL
);

CREATE TABLE theme_variable_version (
  id      INTEGER PRIMARY KEY,
  theme_variable_id INTEGER NOT NULL,
  theme_edition_id INTEGER NOT NULL,
  unused BOOLEAN NOT NULL DEFAULT 0, -- used to mark as not used in an edition
  status INTEGER NOT NULL DEFAULT 0, -- published?
  name    VARCHAR(255) NOT NULL DEFAULT '',
  type    VARCHAR(255) NOT NULL DEFAULT 'text',
  default_value VARCHAR(255),
  description TEXT
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
  parent_layout_id INTEGER,
  theme_style_id INTEGER,
  internal_layout BOOLEAN NOT NULL DEFAULT 0,
  status INTEGER NOT NULL DEFAULT 0, -- published?
  name    VARCHAR(255) NOT NULL DEFAULT '',
  layout TEXT NOT NULL DEFAULT '',
  configuration TEXT NOT NULL DEFAULT '{}'
);

-- CREATE TABLE theme_grid (
--   id INTEGER PRIMARY KEY,
--   theme_id INTEGER NOT NULL,
--   uuid CHAR(20) NOT NULL
-- );

-- CREATE TABLE theme_grid_version (
--   id INTEGER PRIMARY KEY,
--   theme_grid_id INTEGER NOT NULL,
--   theme_edition_id INTEGER NOT NULL,
--   name VARCHAR(255) NOT NULL DEFAULT '',
--   settings TEXT,
-- );

CREATE TABLE theme_style (
  id      INTEGER PRIMARY KEY,
  theme_id INTEGER NOT NULL,
  uuid    CHAR(20) NOT NULL
);

-- grids are loaded in ahead of this style
-- grids without a theme owner are globally available and owned by
-- the system - only the system owner can create/publish these
CREATE TABLE theme_style_version (
  id      INTEGER PRIMARY KEY,
  theme_style_id INTEGER NOT NULL,
  theme_edition_id INTEGER NOT NULL,
  status INTEGER NOT NULL DEFAULT 0, -- published?
--   theme_grid_id INTEGER,
  name    VARCHAR(255) NOT NULL DEFAULT '',
  styles  TEXT
);

CREATE TABLE theme_style_version_typeface_edition (
  id INTEGER PRIMARY KEY,
  theme_style_version_id INTEGER NOT NULL,
  typeface_edition_id INTEGER NOT NULL
);

CREATE TABLE theme_snippet (
  id    INTEGER PRIMARY KEY,
  theme_id INTEGER NOT NULL,
  uuid  char(20) NOT NULL
);

CREATE TABLE theme_snippet_version (
  id    INTEGER PRIMARY KEY,
  theme_edition_id INTEGER NOT NULL,
  theme_snippet_id INTEGER NOT NULL,
  status INTEGER NOT NULL DEFAULT 0, -- published?
  name    VARCHAR(255),
  content TEXT
);

CREATE TABLE theme_asset (
  id INTEGER PRIMARY KEY,
  theme_id INTEGER NOT NULL,
  uuid CHAR(20) NOT NULL
);

CREATE TABLE theme_asset_version (
  id INTEGER PRIMARY KEY,
  theme_edition_id INTEGER NOT NULL,
  theme_asset_id INTEGER NOT NULL,
  status INTEGER NOT NULL DEFAULT 0, -- published?
  size INTEGER,
  filename CHAR(20), -- uuid-like filename for this version
  name VARCHAR(255) NOT NULL,
  type VARCHAR(64) -- the mime type
);


---
--- Component
---

---
--- namespace is uin:uuid:{uuid}
--- we need a configuration mechanism for tying in Perl modules
--- as needed for certain core components
---
CREATE TABLE component (
  id      INTEGER PRIMARY KEY,
  uuid    char(20) NOT NULL,
  board_id INTEGER
);

CREATE TABLE component_edition (
  id      INTEGER PRIMARY KEY,
  component_id INTEGER NOT NULL,
  name    VARCHAR(255) NOT NULL DEFAULT '',
  description TEXT,
  created_on DATETIME NOT NULL,
  closed_on DATETIME
);

CREATE TABLE component_theme (
  id INTEGER PRIMARY KEY,
  component_id INTEGER NOT NULL,
  theme_id INTEGER NOT NULL
);

CREATE TABLE component_theme_version (
  id INTEGER PRIMARY KEY,
  component_theme_id INTEGER NOT NULL,
  theme_edition_id INTEGER NOT NULL,
  prefix VARCHAR(32) NOT NULL
);

CREATE TABLE component_project (
  id INTEGER PRIMARY KEY,
  component_id INTEGER NOT NULL,
  project_id INTEGER NOT NULL
);

CREATE TABLE component_project_version (
  id INTEGER PRIMARY KEY,
  component_project_id INTEGER NOT NULL,
  edition_id INTEGER NOT NULL,
  prefix VARCHAR(32) NOT NULL
);

---
--- Processes
---

CREATE TABLE library (
  id INTEGER PRIMARY KEY,
  uuid CHAR(20) NOT NULL,
  new_project_prefix VARCHAR(32),
  new_theme_prefix   VARCHAR(32),
  board_id INTEGER
);

INSERT INTO library (uuid, new_project_prefix, new_theme_prefix) VALUES ('ypUv1ZbV4RGsjb63Mj8b', 'r', 'r');

CREATE TABLE library_edition (
  id  INTEGER PRIMARY KEY,
  library_id INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL DEFAULT '',
  description TEXT,
  -- namespace VARCHAR(255),
  created_on DATETIME NOT NULL,
  closed_on DATETIME
);

INSERT INTO library_edition (library_id, name, description, created_on, closed_on) VALUES (1, 'Core', 'Core tags', '2012-07-20T00:00:00', '2012-07-20T00:00:00');

CREATE TABLE library_theme (
  id INTEGER PRIMARY KEY,
  library_id INTEGER NOT NULL,
  theme_id INTEGER NOT NULL
);

CREATE TABLE library_theme_version (
  id INTEGER PRIMARY KEY,
  library_theme_id INTEGER NOT NULL,
  library_date DATETIME NOT NULL,
  theme_edition_id INTEGER NOT NULL,
  prefix VARCHAR(32)
);

CREATE TABLE library_project (
  id INTEGER PRIMARY KEY,
  library_id INTEGER NOT NULL,
  project_id INTEGER NOT NULL
);

CREATE TABLE library_project_version (
  id INTEGER PRIMARY KEY,
  library_project_id INTEGER NOT NULL,
  library_date DATETIME NOT NULL,
  edition_id INTEGER NOT NULL,
  prefix VARCHAR(32)
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
