#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'OokOok';
all_from 'lib/OokOok.pm';

requires 'Catalyst::Runtime' => '5.90016';

requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Action::REST' => '1.05';

requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Model::File';
requires 'Catalyst::Model::Adaptor';

requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Params::Nested';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::StatusMessage';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::PerUser';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Unicode::Encoding' => '1.8';

requires 'Catalyst::View::Mason2';
requires 'Catalyst::View::TT';
requires 'Catalyst::View::Thumbnail';

requires 'CatalystX::RoleApplicator';
requires 'CatalystX::Declare';

requires 'Catalyst::Authentication::Store::DBIx::Class';

requires 'Config::General' => '2.51'; 

requires 'Moose';
requires 'MooseX::Declare';
requires 'MooseX::MethodAttributes::Role';
requires 'MooseX::MarkAsMethods' => '0.13';
requires 'MooseX::NonMoose' => '0.16';
requires 'MooseX::Singleton' => '0.29';

requires 'Compress::Zlib' => '2.055';
requires 'Data::UUID' => '1.218';
requires 'Data::Verifier' => '0.54';
requires 'DateTime' => '0.76';
requires 'DateTime::Format::ISO8601';
requires 'DBIx::Class';
requires 'DBIx::Class::Schema::Loader';
requires 'DBD::Pg' => '2.19.3';
requires 'ElasticSearch';
requires 'Exception::Class';
requires 'JSON';
requires 'Lingua::EN::Inflect';
requires 'LWP::Protocol::https';
requires 'Math::Round';
requires 'Net::OAuth';
requires 'Set::Scalar';
requires 'String::CamelCase';
requires 'Workflow';
requires 'XML::LibXML';

requires 'Parse::BBCode';
requires 'Text::Markdown';
requires 'Text::Textile';

requires 'namespace::autoclean';

test_requires 'Test::More' => '0.88';

author_requires 'Parse::Yapp::Driver';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
