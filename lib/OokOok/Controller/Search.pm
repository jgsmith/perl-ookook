use OokOok::Declare;

controller OokOok::Controller::Search {

  use Math::Round ();
  use DateTime::Format::ISO8601 ();
  use feature 'switch';

  under '/' {
    action base as 'search';
  }

  under base {
    final action index as '' {
      my %params = ();
      my $result;
      #if(defined $ctx -> request -> params -> {s}) {
      #  $params{scroll_id} = $ctx -> request -> params -> {s};
      #  $params{scroll} = '5m',
      #  $result = $ctx -> model('ES') -> scroll( %params );
      #}
      #else {
        if(defined $ctx -> request -> params -> {q}) {
          $params{query} -> {query_string} -> {query} =
            $ctx -> model('ES') -> query_parser->filter(
              $ctx -> request -> params -> {q}
            );
          #$params{scroll} = '5m';
          $params{fields} = [qw/__project/];
          #$params{query}->{query_string}->{fuzziness} = 0.5;
          $params{highlight} = {
            fragment_size => 150,
            order => 'score',
            encoder => 'html',
            number_of_fragments => 3,
            require_query_match => 1,
            fields => {
              body => { },
            },
            tags_schema => 'styled',
          };
          $params{index} = "projects";
          $params{type} = [qw/page snippet/];
          $result = $ctx -> model('ES') -> search( %params );
        }
        else {
          $result = {};
        }
      #}
      my %collections = (
        project => OokOok::Collection::Project -> new( c => $ctx),
        page    => OokOok::Collection::Page    -> new( c => $ctx),
      );
      my %docs;
      my $max_score = $result -> {hits} -> {max_score} || 1;
      for my $doc (@{$result -> {hits}{hits}||[]}) {
        next unless $collections{$doc->{'_type'}};
        my $id = $doc -> {_id};
        next unless $id =~ m{^([-A-Za-z0-9_]{20})-(.*)$};
        my($uuid, $date) = ($1, $2);
        my $date_obj = DateTime::Format::ISO8601->parse_datetime( $date );
        my $url_date = $date_obj -> ymd('') . $date_obj -> hms('');
        $collections{project} -> date( $date );
        my $project = $collections{project} -> resource( $doc -> {'fields'} -> {'__project'} );
        next unless $project;
        $collections{page}    -> date( $date );
        $ctx -> stash -> {project} = $project;
        my $item = $collections{$doc->{'_type'}}->resource( $uuid );
        $item -> is_development( 0 ); 
        $item -> date( $date );
        if(!$docs{$uuid}) {
          $docs{$uuid} = {
            instances => [],
            score => 0,
            date => 0,
            type => $doc -> {'_type'},
          };
        }
        my $link;
        given($doc -> {'_type'}) {
          when('project') {
            $link = $ctx -> uri_for(
              '/'.$url_date.'/v/'.$item->id.'/'
            );
          }
          when('page') {
            $link = $ctx -> uri_for(
              '/'.$url_date.'/v/'.$project->id . '/' .
                ($item -> slug_path || '')
            );
          }
        }
              
        push @{$docs{$uuid}{instances}}, {
          doc => $item,
          score => $doc -> {'_score'},
          date => $date_obj,
          id => $uuid,
          link => $link,
          type => $doc->{'_type'},
          highlights => [
            map { 
              s{&lt;.*?&gt;}{}g; $_ 
            } @{$doc->{highlight}->{body}||[]}
          ],
        };
        if($doc->{'_score'} > $docs{$uuid}{score}) {
          $docs{$uuid}{score} = $doc->{'_score'};
          $docs{$uuid}{date} = $date_obj;
        }
      }

      my @docs = sort {
        $b -> {score} <=> $a -> {score} ||
        $b -> {date}  cmp $a -> {date}
      } values %docs;

      if($ctx -> request -> params -> {l} && @docs) {
        return $ctx -> response -> redirect( $docs[0]->{instances}->[0]->{link} );
      }

      for my $d (@docs) {
        $d -> {score} = Math::Round::nearest(0.01, $d -> {score} / $max_score);
        for my $i (@{$d -> {instances}}) {
          $i -> {score} = Math::Round::nearest(0.01, $i -> {score} / $max_score);
        }
      }

      $ctx -> stash -> {results} = $result;
      $ctx -> stash -> {docs} = [ @docs ];
      $ctx -> stash -> {hits} = $result -> {hits}{total} || 0;
      $ctx -> stash -> {q} = $ctx -> request -> params->{q};
      $ctx -> stash -> {template} = "/search";
    }
  }

}

__END__
