use MooseX::Declare;

class OokOok::Template::Parser {

  use Text::Balanced qw(extract_delimited);
  use Data::Dumper ();

  # we're essentially running through emitting events for things we
  # think are special - not really doing a full XML type parse
  # the result is a stack machine that produces the final content

  has prefixes => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

  has _buffer => ( is => 'rw', isa => 'Str', default => '' );

  has _el_stack => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

  method parse ($text) {
    push @{$self -> _el_stack}, {
      prefix => '',
      local => '',
      attrs => {},
      children => []
    };

    my $prefix_regex = '(' . join('|', @{$self -> prefixes}) . '):';
    $prefix_regex = qr{$prefix_regex};

    while(length($text) && $text =~ m{</?$prefix_regex}s) {
      if($text =~ m{\A(.*?)</?$prefix_regex}s) {
        my $c = $1;
        $self -> characters($c);
        $text = substr($text, length($c));
      }
      if($text =~ m{\A<(/?)$prefix_regex(\S+)}s) {
        my($ending, $prefix, $local) = ($1, $2, $3);
        $text = substr($text, length($prefix) + length($local) 
                                              + ($ending ? 3 : 2));
        if($ending) {
          $self -> end_element( $prefix, $local );
        }
        else {
          $self -> start_element( $prefix, $local );
          # now parse attributes
          while($text && $text =~ m{\A(\s*$prefix_regex(\S+)\s*=\s*)}s) {
            my($ent, $aprefix, $attr) = ($1, $2, $3);
            $text = substr($text, length($ent));
            # now parse out balanced quotation
            ($ent, $text) = extract_delimited($text, q{'"});
            $ent = substr($ent, 1, length($ent)-2);
            $self -> attribute( $aprefix, $attr, $ent );
          }
          if($text =~ s{\A\s*/>}{}s) {
            $self -> end_element( $prefix, $local );
          }
          elsif(!($text =~ s{\A\s*>}{}s)) {
            # error parsing
          }
        }
      }
    }
    push @{$self -> _el_stack -> [0] -> {children}}, $text if length($text);
    return $self -> _el_stack -> [0] -> {children};
  }

  method characters ($chars) {
    $self -> _buffer( $self -> _buffer . $chars );
  }

  method start_element ($prefix, $el) {
    push @{$self -> _el_stack -> [0] -> {children}}, $self -> _buffer;
    $self -> _buffer('');
    unshift @{$self -> _el_stack}, { prefix => $prefix, local => $el, attrs => {}, children => [] };
  }

  # we allow attributes to be specified multiple times
  method attribute ($prefix, $name, $value) {
    $self -> _el_stack -> [0] -> {attrs} -> {$prefix} -> {$name} ||= [];
    push @{$self -> _el_stack -> [0] -> {attrs} -> {$prefix} -> {$name}}, $value;
  }

  method end_element ($prefix, $el) {
    # we make sure the end matches
    push @{$self -> _el_stack -> [0] -> {children}}, $self -> _buffer;
    $self -> _buffer('');
    my $info = shift @{$self -> _el_stack};
    push @{$self -> _el_stack -> [0] -> {children}}, $info;
  }
}
