#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'OokOok';
all_from 'lib/OokOok.pm';

requires 'Catalyst::Runtime' => '5.90012';

requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Action::REST';

requires 'Catalyst::Controller::HTML::FormFu';

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
requires 'Catalyst::Plugin::Unicode::Encoding';

requires 'Catalyst::View::TT';
requires 'Catalyst::View::Thumbnail';

requires 'CatalystX::RoleApplicator';
requires 'CatalystX::Declare';

requires 'Catalyst::Authentication::Store::DBIx::Class';

requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'Moose';
requires 'MooseX::MethodAttributes::Role';
requires 'MooseX::MarkAsMethods' => '0.13';
requires 'MooseX::NonMoose' => '0.16';
requires 'MooseX::Singleton' => '0.29';
#requires 'MooseX::Error::Exception::Class';

requires 'Data::UUID';
requires 'Data::Verifier';
requires 'DateTime';
requires 'DateTime::Format::ISO8601';
requires 'DateTime::Format::Natural';
requires 'DBIx::Class';
requires 'DBIx::Class::Schema::Loader';
requires 'ElasticSearch';
requires 'Exception::Class';
requires 'HTML::FormFu';
requires 'HTML::FormFu::Model::DBIC';
requires 'HTML::FillInForm';
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
#requires 'Text::MultiMarkdown';
requires 'Text::Textile';

requires 'CSS::LESSp';

requires 'namespace::autoclean';

test_requires 'Test::More' => '0.88';

author_requires 'Parse::Yapp::Driver';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
