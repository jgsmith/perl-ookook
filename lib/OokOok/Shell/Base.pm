package OokOok::Shell::Base;

use OokOok::Shell::CommandSet;

command '?' => sub {
  my($self, $shell, @bits) = @_;

  if( @bits ) {
    # do help for the command
  }
  else {
    $shell -> print("help!!\n");
  }
};

command quit => sub {
  exit 0;
};

command clear => sub {
  my($self, $shell, @bits) = @_;

  # we can clear vars - start with a $
  # or namespaces - start with xmlns:
  if( @bits == 1 ) {
    if( $bits[0] =~ /^\$(.*)$/ ) {
      # clear variable
    }
    elsif( $bits[0] =~ /^xmlns:(.*)$/ ) {
      # clear namespace
    }
  }
};

command ls => sub {
  my($self, $shell, @bits) = @_;

  $shell -> print("List resources at the current level\n");
};

command cd => sub {
  my($self, $shell, @bits) = @_;

  $shell -> print("Dive into a resource to access embedded resources\n");
};


1;

__END__
