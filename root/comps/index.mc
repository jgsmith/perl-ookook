<%args>
$.posts => sub { [] }
</%args>
<div class="hero-unit" style="text-align: center;">
  <h1>OokOok!</h1>
  <form action="<% $c->uri_for("/search") %>">
    <input type="text" name="q" class="span6" /><br />
    <button type="submit" class="btn btn-primary">Search</button>
    <button type="submit" class="btn" name="l" value="1">I'm feeling lucky</button>
  </form>
</div>

<!-- we want to have a display of recently updated projects below
     that automatically loads as you scroll down the page -->
<section id="content" class="row">
% for my $post (@{$.posts}) {
  <div class="box <% $post->{class} %>">
    <h1><a href="<% $post->{link} %>"><% $post->{title} | H %></a></h1>
    <% $post->{content} %>
  </div>
% }
</section>
<nav id="page-nav">
  <a href="<% $c->uri_for("/?page=2") %>"></a>
</nav>
<script src="<% $c->uri_for("/static/js/masonry.js") %>"></script>
<script src="<% $c->uri_for("/static/js/jquery.infinitescroll.min.js") %>"></script>
<script>
  $(function(){
    
    var $container = $('#container');
    
    $container.imagesLoaded(function(){
      $container.masonry({
        itemSelector: '.box',
        columnWidth: 100
      });
    });
    
    $container.infinitescroll({
      navSelector  : '#page-nav',    // selector for the paged navigation 
      nextSelector : '#page-nav a',  // selector for the NEXT link (to page 2)
      itemSelector : '.box',     // selector for all items you'll retrieve
      loading: {
          finishedMsg: 'No more pages to load.',
          img: 'http://i.imgur.com/6RMhx.gif'
        }
      },
      // trigger Masonry as a callback
      function( newElements ) {
        // hide new items while they are loading
        var $newElems = $( newElements ).css({ opacity: 0 });
        // ensure that images load before adding to masonry layout
        $newElems.imagesLoaded(function(){
          // show elems now they're ready
          $newElems.animate({ opacity: 1 });
          $container.masonry( 'appended', $newElems, true ); 
        });
      }
    );
    
  });
</script>
