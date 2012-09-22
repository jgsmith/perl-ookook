# OokOok

OokOok is a temporal content and data management system, allowing
sustainable, reproducible citation of scholarly works and resources.

The goal is to create a platform for dynamic scholarly projects based
on descriptive technologies such as HTML5, CSS, RDF, and Open Annotation.

For more information about the design, follow my blog posts at
[http://www.jamesgottlieb.com/category/dh/ookook/](http://www.jamesgottlieb.com/category/dh/ookook/).

## Testing

OokOok requires the following non-Perl services:

* PostgreSQL 9.2 or later
* ElasticSearch

To install the database schema, set the proper connection information in
the ookook.conf file. Then, run the following commands to prepare and install
the schema:

% ./script/ookook_migration.pl prepare
% ./script/ookook_migration.pl install

You will need to run the following insert statements to get the core taglib:

 INSERT INTO "library" 
     (uuid, new_project_prefix, new_theme_prefix)
 VALUES 
     ('ypUv1ZbV4RGsjb63Mj8b', 'r', 'r');

 INSERT INTO "library_edition"
     (library_id, name, description, created_on, closed_on, published_for)
 VALUES 
     (1, 'Core', 'Core tags', now(), now(), tsrange(now()::timestamp, 
      NULL::timestamp, '[)'));

Once the database is in place, you can run script/ookook_server.pl 
to test the application.

## Roadmap

OokOok is under active development. We expect to develop the following 
features along the rough timeline as noted.

* 2012
    - Simple CMS (project pages, snippets; theme layouts, styles)
    - Assets
    - Social management (boards)

* 2013
    - Annotation databases
    - Simple triple store databases
    - Simple presentations of annotations and triple store data
    - Algorithms

* 2014
    - User-defined processes and presentations
    - Applications
    - Workflows

