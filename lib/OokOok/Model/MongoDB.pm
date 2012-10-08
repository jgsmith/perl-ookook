use CatalystX::Declare;

# PODNAME: OokOok::Model::MongoDB

# ABSTRACT: Model glue for MongoDB

model OokOok::Model::MongoDB
      extends Catalyst::Model::MongoDB 
{

  method store_file ($file, HashRef $data) {
    my %meta;
    $meta{'content-type'} = $data->{mime_type};
    $self -> gridfs -> put($file, \%meta);
  }

  method update_file (Str $id, $file, HashRef $data) {
    my %meta;
    $meta{'content-type'} = $data->{mime_type};
    $meta{'_id'} = $id;
    $self -> gridfs -> put($file, \%meta);
  }

  method get_file (Str $id) {
    $self -> gridfs -> get($id);
  }
}
