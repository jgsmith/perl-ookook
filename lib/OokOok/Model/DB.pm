use CatalystX::Declare;

# PODNAME: OokOok::Model::DB

# ABSTRACT: Catalyst DBIC Schema model

model OokOok::Model::DB
  extends Catalyst::Model::DBIC::Schema
{

  $CLASS->config(
    schema_class => 'OokOok::Schema',
    
    connect_info => {
      dsn => 'dbi:SQLite:ookook.db',
      user => '',
      password => '',
      #on_connect_do => q{PRAGMA foreign_keys = ON},
    }
  );

}

__END__

=head1 SYNOPSIS

See L<OokOok>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<OokOok::Schema>

=cut

1;
