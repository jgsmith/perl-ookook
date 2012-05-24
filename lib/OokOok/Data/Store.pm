package OokOok::Data::Store;
use namespace::autoclean;
use Moose;
use Set::Scalar;
use OokOok::Event;

has '_spo' => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { +{} },
);

has '_ops' => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { +{} },
);

has '_types' => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { +{} },
);

has '_properties' => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { +{} },
);

has 'onModelChange' => (
  is => 'ro',
  isa => 'OokOok::Event',
  default => sub {
    OokOok::Event->new;
  },
);

sub size {
  scalar keys %{$_[0] -> _spo};
}

sub contains {
  exists $_[0]->_spo->{$_[1]};
}

sub items {
  keys %{$_[0] -> _spo};
}

sub _indexRemove {
  my($self, $index, $x, $y, $z, $clean) = @_;

  my($hash, $array, $counts);

  $hash = $index->{$x};
  return if !$hash;

  $array = $hash -> {values}->{$y};
  $counts = $hash -> {counts} -> {$y};

  return if !$array || !$counts;

  $counts->{$z} --;

  if($counts->{$z} < 1) {
    $array -> delete($z);
    delete $counts->{$z};
 
    if($array -> size == 0) {
      delete $hash->{values}->{$y};
      delete $hash->{counts}->{$y};
    }

    if($clean && scalar(keys %$hash) == 0) {
      delete $index->{$x};
    }
  }
}

sub _indexPut {
  my($self, $index, $x, $y, $z) = @_;

  my($hash, $array, $counts);

  $hash = $index->{$x};

  if(!defined $hash) {
    $hash = {
      values => {},
      counts => {}
    };
    $index->{$x} = $hash;
  }

  $array = $hash -> {values} -> {$y};
  $counts = $hash -> {counts} -> {$y};

  if(!defined $array) {
    $array = Set::Scalar->new;
    $hash -> {values} -> {$y} = $array;
  }

  if(!defined $counts) {
    $counts = {};
    $hash -> {counts} -> {$y} = $counts;
  }

  if($array->has($z)) {
    $counts->{$z} ++;
  }
  else {
    $array->insert($z);
    $counts -> {$z} = 1;
  }
}

sub _indexFillSet {
  my($self, $index, $x, $y, $set, $filter) = @_;

  my($hash, $array);

  $hash = $index->{$x};

  if(defined $hash) {
    $array = $hash->{values}->{$y};
    if(defined $array) {
      if(defined $filter) {
        $set->insert( $filter -> intersection($array) -> members );
      }
      else {
        $set->insert( $array -> members );
      }
    }
  }
}

sub _getUnion {
  my($self, $index, $xSet, $y, $set, $filter) = @_;

  if(!defined $set) {
    $set = Set::Scalar -> new;
  }

  while(defined(my $x = $xSet->each)) {
    $self -> _indexFillSet($index, $x, $y, $set, $filter);
  }
  return $set;
}

sub addProperty {
  my($self, $nom, $options) = @_;

  my $prop = OokOok::Data::Property->new($options);
  $self->_properties->{$nom} = $prop;
}

sub getProperty {
  my($self, $nom) = @_;

  my $prop = $self->_properties->{$nom};
  if(!$prop) {
    $prop = OokOok::Data::Property->new;
    $self->_properties->{$nom} = $prop;
  }
  return $prop;
}

sub addType {
  my($self, $nom, $options) = @_;
  my $type = OokOok::Data::Type->new($options);
  $self->_types->{$nom} = $type;
}

sub getType {
  my($self, $nom) = @_;

  my $type = $self->_types->{$nom};
  if(!$type) {
    $type = OokOok::Data::Type->new;
    $self->_types->{$nom} = $type;
  }
  return $type;
}

sub getItem {
  my($self, $id) = @_;

  my $t = $self -> _spo -> {$id};
  if($t) {
    $t = $t -> {values};
  }
  if(!$t) {
    $t = {};
  }
  return $t;
}

sub getItems {
  my($self, @ids) = @_;

  my(@items) = (map { $self -> getItem($_) } @ids);
  if(wantarray) { return  @items; }
  else          { return \@items; }
}

sub _indexRemoveFn {
  my($self, $s, $p, $o, $clean) = @_;

  $self -> _indexRemove($self->_spo, $s, $p, $o, $clean);
  $self -> _indexRemove($self->_ops, $o, $p, $s, $clean);
}

sub _removeValues {
  my($self, $id, $p, $list, $cleanup) = @_;

  for my $o (@$list) {
    $self->_indexRemoveFn($id, $p, $o, $cleanup);
  }
}

sub _removeItem {
  my($self, $id) = @_;

  my $entry = $self -> getItem($id);

  while(my($p, $set) = each(%$entry)) {
    if($p ne "id") {
      $self->_removeValues($id, $p, [$set->members], 1);
    }
  }
} 

sub removeItems {
  my($self, @ids) = @_;

  foreach my $id (@ids) {
    $self->_removeItem($id);
  }

  $self->onModelChange->fire($self, \@ids);
}

sub _indexPutFn {
  my($self, $s, $p, $o) = @_;

  $self->_indexPut($self->_spo, $s, $p, $o);
  $self->_indexPut($self->_ops, $o, $p, $s);
}

sub _updateItem {
  my($self, $entry) = @_;

  my($id, $changed) = ($entry->{id});
  $id = ($id -> members)[0] if defined $id;
  my($old_item) = $self -> getItem($id);

  my($add, $sub, $p, $items);
  $changed = 0;

  while(($p, $items) = each(%$entry)) {
    next if $p eq "id";

    if(ref $items eq "ARRAY") {
      $items = Set::Scalar->new(@$items);
    }
    elsif(!ref $items) {
      $items = Set::Scalar->new($items);
    }
    if(exists $old_item->{$p}) {
      $add = $items - $old_item->{$p};
      $sub = $old_item->{$p} - $items;
    }
    else {
      $add = $items;
      $sub = Set::Scalar->new;
    }
    $changed += $add-> size + $sub->size;
    $self->_removeValues($id, $p, [$sub->members]);
    for my $o ($add->members) {
      $self->_indexPutFn($id, $p, $o);
    }
  }
  return $changed != 0;
}

sub updateItems {
  my $self = shift;
  my @items;
  my @ids;

  if(ref $_[0] eq "HASH") {
    @items =  @_ ;
  }
  else {
    @items = @$_[0];
  }

  my @changedIds = ();
  my($id);

  for my $item (@items) {
    $id = $item->{id};
    if($id) {
      $id = ($id -> members)[0];
      if($id) {
        if($self -> _updateItem($item)) {
          push @ids, $id;
        }
      }
    }
  }
  if(@ids) {
    $self->onModelChange->fire($self, \@ids);
  }
}

sub _loadItem {
  my($self, $item) = @_;

  my($p, $items);
  my $id = $item->{id};
  my $loaded = 0;
  if($id) {
    if(ref $id eq "ARRAY") {
      $id = $id->[0];
    }
    elsif($id -> isa("Set::Scalar")) {
      $id = ($id->members)[0];
    }

    while(($p, $items) = each(%$item)) {
      next if $p eq "id";

      if(ref $items eq "ARRAY") {
        $items = Set::Scalar->new(@$items);
      }
      elsif(!ref $items) {
        $items = Set::Scalar->new($items);
      }
      $loaded += $items -> size;
      for my $o ($items->members) {
        $self->_indexPutFn($id, $p, $o);
      }
    }

    return $id if $loaded > 0;
  }
}

sub loadItems {
  my $self = shift;

  my @id_list = grep { defined } map { $self -> _loadItem($_) } @_;

  if(@id_list) {
    $self->onModelChange->fire($self, \@id_list);
  }
}

sub getObjectsUnion {
  my($self, $subjects, $p, $set, $filter) = @_;

  $self -> getUnion($self->_spo, $subjects, $p, $set, $filter);
}

sub getSubjectsUnion {
  my($self, $objects, $p, $set, $filter) = @_;

  $self -> getUnion($self->_ops, $objects, $p, $set, $filter);
}

1;

__END__
