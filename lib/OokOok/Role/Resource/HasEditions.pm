use MooseX::Declare;

role OokOok::Role::Resource::HasEditions {

  method edition_resource_class {
    blessed($self) . "Edition";
  }

  method edition {
    $self -> edition_resource_class -> new(
      c => $self -> c,
      source => $self -> source -> current_edition,
    );
  }
}
