use CatalystX::Declare;

# PODNAME: OokOok::Model::MongoDB

# ABSTRACT: Model glue for MongoDB

model OokOok::Model::MongoDB
      extends Catalyst::Model::MongoDB 
{

  method store_file (Str $type, $file, HashRef $data) {
    my %meta;
    $meta{'content-type'} = $data->{mime_type};
    seek($file, 0, 0);
    binmode($file, ':raw');
    $self -> g($self->gridfsname . '.' . $type) -> put($file, \%meta);
  }

  method update_file (Str $type, Str $id, $file, HashRef $data) {
    my %meta;
    $meta{'content-type'} = $data->{mime_type};
    $meta{'_id'} = $self->oid($id);
    seek($file, 0, 0);
    binmode($file, ':raw');
    $self -> g($self->gridfsname . '.' . $type) -> put($file, \%meta);
  }

  method get_file (Str $type, Str $id) {
    $self -> g($self->gridfsname . '.' . $type) -> get($self -> oid($id));
  }
}
