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

To install all of the Perl modules that OokOok uses, download a recent
trial package of the distribution and run the following commands:

    % tar xzf OokOok-0.___.tgz
    % cd OokOok-0.___
    % cpanm --installdeps .

Some modules may need handholding depending on the system and which non-Perl
libraries are already installed.

To install the database schema, set the proper connection information in
the ookook.conf file. Then, run the following commands in the distribution
directory to install the schema:

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

At the moment:
    - Boards and permissions

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


# Installing on an Amazon EC2 Instance (Ubuntu 12.04)

OokOok is designed to host many projects, so while the installation process
seems a bit steep, remember that it's a one-time cost that can be spread
across many projects.

These instructions assume that everything is running on a single instance.
If you want to run on multiple instances, I assume that you know enough
about how the various components work that you can figure out how the
configuration changes for a distributed installation.

OokOok is not ready for distribution on CPAN yet, so these instructions
are a bit more manual than they will be once we get past initial development.

OokOok requires about a gigabyte of disk space to install all of the Perl
modules, PostgreSQL, and ElasticSearch. Additional disk space is needed
for the various databases and asset stores.


## ElasticSearch

Follow the directions at https://gist.github.com/2026107 except change
the version of ElasticSearch to the most recent version available
at https://github.com/elasticsearch/elasticsearch/downloads .


## PostgreSQL 9.2

Until the Ubuntu packages are upgraded to 9.2, you'll need to pull the
packages from elsewhere.

N.B.: The configuration file that comes with OokOok assumes that the 
database is named `ookook_dev` and accessible by the user running the 
application without needing any authentication. Edit the `conf/ookook.conf` 
file to reflect the database name and credentials that you want to use.

If PostgreSQL 9.2 is not the current version by default, then you'll need
to add the repository for newest versions:

    # add-apt-repository ppa:pitti/postgresql
    # apt-get update

Then, to install PostgreSQL 9.2:

    # apt-get install libpq-dev postgresql-9.2


## Perl Depenencies

You will need to install the build tools before you can use CPAN:

    # apt-get install build-essential

Some Perl modules are best installed using `apt-get`:

    # apt-get install libxml-libxml-perl
    # apt-get install libdbix-class-perl
    # apt-get install libdbix-class-schema-loader-perl

The easiest way to get up to speed with the rest of the Perl modules 
is to install `cpanm`:

    # cpan App::cpanminus

Then, download and untar the most recent trial distribution of OokOok. In
the distribution directory, run the following commands:

    # cpanm --installdeps .

This will get most of the Perl modules. To get the rest, you will need
a combination of packaged libraries and subsequent runs of CPAN.

Don't be surprised if this takes an hour or two. There are a lot of
dependencies. Run these commands in a screen session and you won't have
to worry about disconnections interrupting the processes.


### Optional Installation of Some Perl Dependencies

If you prefer using apt-get for modules, then you can get quite a few
installed through the following commands (but don't run these if you
already ran the `cpanm` command above):

    # apt-get install libcatalyst-perl libcatalyst-modules-perl
    # apt-get install libcatalyst-modules-extra-perl
    # apt-get install libcatalyst-action-rest-perl
