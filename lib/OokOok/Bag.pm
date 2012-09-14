use MooseX::Declare;

# PODNAME: OokOok::Bag

# ABSTRACT: Support writing Bagit bags archiving resource collections

class OokOok::Bag {
  use Archive::Tar::Wrapper;
  use Encode;
  use Digest::MD5 qw(md5_hex);
  use Digest::SHA1 qw(sha1_hex);
  use File::Temp ();
  use Carp;
  use YAML::Any qw/Dump/;

  has md5data => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
  );

  has sha1data => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
  );

  #has _on_disk_dir => (
  #  is => 'ro',
  #  isa => 'Str',
  #  builder => '_create_tmp_dir',
  #);

  has _archive => (
    is => 'rw',
    isa => 'Archive::Tar::Wrapper',
    default => sub { Archive::Tar::Wrapper -> new }
  );

  has _meta_info => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [ +{} ] }
  );

  has _data_dir => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { ['data'] }
  );

  #method _create_tmp_dir { File::Temp -> newdir }

  method _write_file ($file, $content) {
    $self -> _archive -> add($file, \$content);
  }

  method _read_file ($file) {
    my $path = $self -> _archive -> locate($file);
    my $content;
    if($path) {
      open my $fh, "<", $path or croak "Unable to read content from bag";
      local($/);
      $content = <$fh>;
      close $fh;
    }
    return $content;
  }

  method add_data ($name, $content) {
    $content = encode('utf8', $content) if utf8::is_utf8($content);
    my $dir = join("/", @{$self -> _data_dir});
    push @{$self -> md5data}, md5_hex($content) . " $dir/$name";
    push @{$self -> sha1data}, sha1_hex($content) . " $dir/$name";
    $self -> _write_file("$dir/$name", $content);
  }

  method get_data ($name) {
    my $dir = join("/", @{$self -> _data_dir});
    my $content = $self -> _read_file("$dir/$name");
    decode('utf8', $content);
  }

  method _rollback_data_directory {
    my $meta = shift @{$self -> _meta_info};
    if(keys %$meta) {
      $self -> add_data( "META.yml", Dump( $meta ) );
    }
    pop @{$self -> _data_dir};
  }

  method add_meta ($key, $value) {
    $self -> _meta_info -> [0] -> {$key} = $value;
  }

  method with_data_directory (Str $dir, CodeRef $yield) {
    push @{$self -> _data_dir}, $dir;
    unshift @{$self -> _meta_info}, +{};
    my $guard = OokOok::Bag::Guard -> new(
      rollback => sub { $self -> _rollback_data_directory },
    );
    $self -> $yield;
    $guard -> rollback;
  }

  method write {

    my $meta = shift @{$self -> _meta_info};
    if($meta && keys %$meta) {
      $self -> _write_file("META.yml", Dump( $meta ));
    }

    # add metadata pieces at top-level of bag
    pop @{$self -> _data_dir};
    $self -> _write_file("manifest-md5.txt", encode('utf-8', join("\n", @{$self -> md5data})));
    $self -> _write_file("manifest-sha1.txt", encode('utf-8', join("\n", @{$self -> sha1data})));

    $self -> _write_file("bagit.txt", encode('utf-8', <<EOF));
BagIt-version: 0.97
Tag-File-Character-Encoding: UTF-8
EOF
    my $version = $OokOok::VERSION || 'dev';
    $self -> _write_file("package-info.txt", encode('utf-8', <<EOF));
Bag-Software-Agent: OokOok $version (http://search.cpan.org/dist/OokOok)
EOF

    my $tempfile = File::Temp->new(UNLINK => 0, SUFFIX => ".tgz");
    $tempfile -> unlink_on_destroy(1);
    $self -> _archive -> write($tempfile -> filename, 1);
    $tempfile;
  }
}

class OokOok::Bag::Guard {
  has _rollback => (
    is => 'rw',
    isa => 'Maybe[CodeRef]',
    predicate => 'has_rollback',
    init_arg => 'rollback',
  );

  has _rolledback => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
  );

  method rollback {
    if(!$self -> _rolledback && $self -> has_rollback) {
      $self -> _rollback -> ();
      $self -> _rolledback(1);
    }
  }

  # forget how to rollback so we don't do it accidently
  method commit {
    $self -> _rolledback(1);
    $self -> _rollback(sub { });
  }

  method DEMOLISH {
    $self -> rollback;
  }
}
