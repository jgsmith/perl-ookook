use CatalystX::Declare;

controller OokOok::Controller::Style
   extends OokOok::Base::Player
{
  $CLASS -> config(
    map => {
      'text/css' => [ 'View', 'CSS' ],
    },
    default => 'text/css',
  );

  under '/' {
    action base as 's' {
      $ctx -> stash -> {collection} = OokOok::Collection::Project -> new(
        c => $ctx,
      );
    }

    action tbase as 'ts' {
      $ctx -> stash -> {collection} = OokOok::Collection::Theme -> new(
        c => $ctx,
      );
    }
  }

  under tbase {
    action play_tbase ($uuid) as '' {
      $self -> play_base($ctx, $uuid);
    }
  }

  under play_tbase {
    action tstyle_base ($uuid) as 'style' {
      my $theme = $ctx -> stash -> {theme};
      my $style = $theme -> style($uuid);

      if(!$style) {
        $ctx -> detach(qw/Controller::Root default/);
      }

      $ctx -> stash -> {resource} = $style;
    }
  }

  under tstyle_base {
    final action tstyle as '' isa REST;
  }

  under play_base {
    action style_base ($uuid) as 'style' {
      my $theme = $ctx -> stash -> {project} -> theme;
      my $style = $theme -> style($uuid);

      if(!$style) {
        $ctx -> detach(qw/Controller::Root default/);
      }

      $ctx -> stash -> {resource} = $style;
    }
  }

  under style_base {
    final action style as '' isa REST;
  }

  method style_GET ($ctx) {
    # TODO: cache compiled stylesheets
    $ctx -> stash -> {rendering} = $ctx -> stash -> {resource} -> render;
    $ctx -> stash -> {template} = 'style/style.tt2';
    $ctx -> forward( $ctx -> view('HTML') );
  }

  method tstyle_GET ($ctx) {
    $self -> style_GET($ctx);
  }
}
