use MooseX::Declare;

# PODNAME: OokOok::Shell

# ABSTRACT: interactive console for managing OokOok

class OokOok::Shell with MooseX::Getopt {
  use Moose::Exporter;
  use OokOok::Shell::Base;
  use IO::Handle;
  use Module::Load ();

  our $VERSION = "0.0.1";

  Moose::Exporter -> setup_import_methods(
    as_is => [ qw( shell ) ]
  );

  has 'd' => (accessor => 'debug', is => 'rw', isa => 'Bool', default => 0,
              documentation => 'Turns on debug mode');
  has 'p'  => (accessor => 'suppress_pager',  is => 'rw', isa => 'Bool', default => 0,
              documentation => 'Suppress use of a pager' );
  has 'r' => (accessor => 'suppress_readline', is => 'rw', isa => 'Bool', default => sub { ! -t STDIN },
              documentation => 'Suppress use of Term::ReadLine' );
  has 'f' => (accessor => 'config_file', is => 'rw', isa => 'Str', default => "$ENV{'HOME'}/.ookookrc",
              documentation => 'Use given rc file instead of ~/.ookookrc' );

  has '_prompt' => ( accessor => 'prompt', is => 'rw', isa => 'Str', default => 'ookook>' );
  has '_in'     => ( accessor => 'IN', is => 'rw' );
  has '_out'    => ( accessor => 'OUT', is => 'rw' );
  has '_term'   => ( accessor => 'term', is => 'rw' );
  has '_sn'     => ( accessor => 'suppress_narrative', is => 'rw', isa => 'Bool' );
  has '_silent' => (accessor => 'silent', is => 'rw', isa => 'Bool', default => 0 );

  # used to manage the first word of a command
  has '_command_handlers' => (accessor => 'handlers', is => 'rw', isa => 'HashRef', default => sub { +{ } } );

  sub shell {
    OokOok::Shell -> new_with_options() -> run();
  }

  method print (@stuff) {
    return if $self -> silent;
    $self -> OUT -> print(@stuff);
  }

  method run {
    if( $self -> help_flag ) {
      print $self -> usage, "\n";
      return;
    }

    $self -> suppress_narrative( scalar( @{$self -> extra_argv} ) > 0 );

    if( $self -> suppress_narrative ) {
      $self -> suppress_readline(1);
    }

    if( ! $self -> suppress_readline ) {
      eval { Module::Load::load('Term::ReadLine'); };
      $self -> suppress_readline(1) if $@;
    }

    if( $self -> suppress_readline ) {
      $self -> OUT(\*STDOUT);
      $self -> IN(\*STDIN);
    }
    else {
      $self -> term(Term::ReadLine -> new("OokOok Shell"))
        if( ! $self -> term
           or $self -> term -> ReadLine eq 'Term::Readline::Stub'
          );
      my $odef = select STDERR;
      $| = 1;
      select STDOUT;
      $| = 1;
      select $odef;
      $self -> OUT( $self -> term -> OUT || \*STDOUT );
      $self -> IN ( $self -> term -> IN  || \*STDIN  );
    }

    unless( $self -> suppress_narrative ) {
      $self -> print("\nookook shell -- OokOok (v$OokOok::Shell::VERSION)\n");
      $self -> print( "ReadLine support enabled\n") unless $self -> suppress_readline;
      $self -> print("Pager support enabled\n") unless $self -> suppress_pager;
    }

    eval {
      Module::Load::load('OokOok::Shell::Base');
      OokOok::Shell::Base -> init_commands($self);
    };

    $self -> find_commands('OokOok::Shell');

    unless( $self -> suppress_narrative ) {
      print "\n";
    }

    if( -f ($self -> config_file) && -r _ ) {
      $self -> print("Reading rc file ", $self -> config_file, "\n")
        unless $self -> suppress_narrative;
      $self -> read_file($self -> config_file);
    }

    if( $self -> suppress_readline ) {
      $self -> interpret($_) while(<>);
    }
    else {
      $self -> interpret($_)
        while defined($_ = $self -> term -> readline($self -> prompt));
    }

    if(! $self -> suppress_narrative ) {
      $self -> print("\n");
    }
  }

  method add_handler ($prefix, $obj) {
    $self -> handlers -> {$prefix} = $obj;
  }

  method read_file ($file) {
    if(-f $file && -r _) {
      my $fh;
      if(open $fh, "<", $file) {
        my $old_silent = $self -> silent;
        $self -> silent(1);
        while(<$fh>) {
          chomp;
          $self -> interpret($_);
        }
        $self -> silent($old_silent);
      }
    }
  }
  
  method find_commands {
  }

  method interpret ($command) {
    my @bits = split(/\s+/, $command);
    if( @bits && $self -> handlers -> {$bits[0]} ) {
      $self -> handlers -> {shift @bits} -> immediate($self, @bits);
    }
    else {
      OokOok::Shell::Base -> instance -> immediate($self, @bits);
    }
  }
}

__END__

=head1 SYNOPSIS

 % perl -MOokOok::Shell -e shell

=head1 DESCRIPTION
