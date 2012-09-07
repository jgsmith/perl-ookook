package OokOok::Template::TagLibrary::Core;

use OokOok::Template::TagLibrary;

my $SAMPLE_CONTENT = <<'EOHTML';
<p>The purpose of this HTML is to help determine what default settings are with CSS and to make sure that all possible HTML Elements are included in this HTML so as to not miss any possible Elements when designing a site.</p>
<hr/>
<h1>Heading 1</h1>
<h2>Heading 2</h2>
<h3>Heading 3</h3>
<h4>Heading 4</h4>
<h5>Heading 5</h5>
<h6>Heading 6</h6>
<hr/>
<h2>Paragraph</h2>
<p>Lorem ipsum dolor sit amet, <a href="#" title="test link">test link</a> adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. Donec faucibus. Nunc iaculis suscipit dui. Nam sit amet sem. Aliquam libero nisi, imperdiet at, tincidunt nec, gravida vehicula, nisl. Praesent mattis, massa quis luctus fermentum, turpis mi volutpat justo, eu volutpat enim diam eget metus. Maecenas ornare tortor. Donec sed tellus eget sapien fringilla nonummy. Mauris a ante. Suspendisse quam sem, consequat at, commodo vitae, feugiat in, nunc. Morbi imperdiet augue quis tellus.</p>
<p>Lorem ipsum dolor sit amet, <em>emphasis</em> consectetuer adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. Donec faucibus. Nunc iaculis suscipit dui. Nam sit amet sem. Aliquam libero nisi, imperdiet at, tincidunt nec, gravida vehicula, nisl. Praesent mattis, massa quis luctus fermentum, turpis mi volutpat justo, eu volutpat enim diam eget metus. Maecenas ornare tortor. Donec sed tellus eget sapien fringilla nonummy. Mauris a ante. Suspendisse quam sem, consequat at, commodo vitae, feugiat in, nunc. Morbi imperdiet augue quis tellus.</p>
<h2>Body Text Sizes</h2>
<p>
<span style="font-size: 90%;">90% ABCDEFGOQPRSWXYZ abcdefghijmnrpqszwuvt</span><br/>
<span style="font-size: 80%;">80% ABCDEFGOQPRSWXYZ abcdefghijmnrpqszwuvt</span><br/>
<span style="font-size: 70%;">70% ABCDEFGOQPRSWXYZ abcdefghijmnrpqszwuvt</span><br/>
<span style="font-size: 60%;">60% ABCDEFGOQPRSWXYZ abcdefghijmnrpqszwuvt</span><br/>
<span style="font-size: 50%;">50% ABCDEFGOQPRSWXYZ abcdefghijmnrpqszwuvt</span><br/>
</p>
<hr/>
<h2>List Types</h2>
<h3>Definition List</h3>
<dl>
<dt>Definition List Title</dt>
<dd>This is a definition list division.</dd>
</dl>
<h3>Ordered List</h3>
<ol>
<li>List Item 1</li>
<li>List Item 2</li>
<li>List Item 3</li>
</ol>
<h3>Unordered List</h3>
<ul>
<li>List Item 1</li>
<li>List Item 2</li>
<li>List Item 3</li>
</ul>
<hr/>
<h2>Forms</h2>
<fieldset>
<legend>Legend</legend>
<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. Donec faucibus. Nunc iaculis suscipit dui. Nam sit amet sem. Aliquam libero nisi, imperdiet at, tincidunt nec, gravida vehicula, nisl. Praesent mattis, massa quis luctus fermentum, turpis mi volutpat justo, eu volutpat enim diam eget metus.</p>
<form>
<h2>Form Element</h2>
<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. Donec faucibus. Nunc iaculis suscipit dui.</p>
<p><label for="text_field">Text Field:</label><br/>
		<input type="text"/></p>
<p><label for="text_area">Text Area:</label><br/>
		<textarea></textarea></p>
<p><label for="select_element">Select Element:</label></p>
<select name="select_element">
			<optgroup label="Option Group 1">
<option value="1">Option 1</option>
<option value="2">Option 2</option>
<option value="3">Option 3</option>
			</optgroup>
			<optgroup label="Option Group 2">
<option value="1">Option 1</option>
<option value="2">Option 2</option>
<option value="3">Option 3</option>
			</optgroup><br/>
		</select>

<p><label for="radio_buttons">Radio Buttons:</label></p>
<p>			<input type="radio" class="radio" name="radio_button" value="radio_1"/> Radio 1<br/><br/>
				<input type="radio" class="radio" name="radio_button" value="radio_2"/> Radio 2<br/><br/>
				<input type="radio" class="radio" name="radio_button" value="radio_3"/> Radio 3<br/>
		</p>
<p><label for="checkboxes">Checkboxes:</label></p>
<p>			<input type="checkbox" class="checkbox" name="checkboxes" value="check_1"/> Radio 1<br/><br/>
				<input type="checkbox" class="checkbox" name="checkboxes" value="check_2"/> Radio 2<br/><br/>
				<input type="checkbox" class="checkbox" name="checkboxes" value="check_3"/> Radio 3<br/>
		</p>
<p><label for="password">Password:</label></p>
<p>			<input type="password" class="password" name="password"/>
		</p>
<p><label for="file">File Input:</label><br/>
			<input type="file" class="file" name="file"/>
		</p>
<p><input class="button" type="reset" value="Clear"/> <input class="button" type="submit" value="Submit"/>
		</p>
</form>
</fieldset>
<hr/>
<h2>Tables</h2>
<table cellspacing="0" cellpadding="0">
<tr>
<th>Table Header 1</th>
<th>Table Header 2</th>
<th>Table Header 3</th>
</tr>
<tr>
<td>Division 1</td>
<td>Division 2</td>
<td>Division 3</td>
</tr>
<tr class="even">
<td>Division 1</td>
<td>Division 2</td>
<td>Division 3</td>
</tr>
<tr>
<td>Division 1</td>
<td>Division 2</td>
<td>Division 3</td>
</tr>
</table>
<hr/>
<h2>Misc Stuff &#x2013; abbr, acronym, pre, code, sub, sup, etc.</h2>
<p>Lorem <sup>superscript</sup> dolor <sub>subscript</sub> amet, consectetuer adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. <cite>cite</cite>. Nunc iaculis suscipit dui. Nam sit amet sem. Aliquam libero nisi, imperdiet at, tincidunt nec, gravida vehicula, nisl. Praesent mattis, massa quis luctus fermentum, turpis mi volutpat justo, eu volutpat enim diam eget metus. Maecenas ornare tortor. Donec sed tellus eget sapien fringilla nonummy. <acronym title="National Basketball Association">NBA</acronym> Mauris a ante. Suspendisse quam sem, consequat at, commodo vitae, feugiat in, nunc. Morbi imperdiet augue quis tellus.  <abbr title="Avenue">AVE</abbr></p>
<pre>

<p>

Lorem ipsum dolor sit amet,

 consectetuer adipiscing elit.

 Nullam dignissim convallis est.

 Quisque aliquam. Donec faucibus. 

Nunc iaculis suscipit dui. 

Nam sit amet sem. 

Aliquam libero nisi, imperdiet at,

 tincidunt nec, gravida vehicula,

 nisl. 

Praesent mattis, massa quis 

luctus fermentum, turpis mi 

volutpat justo, eu volutpat 

enim diam eget metus. 

Maecenas ornare tortor. 

Donec sed tellus eget sapien

 fringilla nonummy. 

<acronym title="National Basketball Association">NBA</acronym> 

Mauris a ante. Suspendisse

 quam sem, consequat at, 

commodo vitae, feugiat in, 

nunc. Morbi imperdiet augue

 quis tellus.  

<abbr title="Avenue">AVE</abbr></p></pre>
<blockquote><p>
	&#x201C;This stylesheet is going to help so freaking much.&#x201D; <br/>-Blockquote
</p></blockquote>
EOHTML

# processes content
element 'snippet' => (
  uses_content => 1, # we'll get the node for further processing
  escape_text => 0,
  attributes => {
    "" => {
      name => 'Str', # not an expression
    }
  },
  impl => 'element_snippet',
);

# no child parts
element 'content' => (
  escape_text => 0,
  attributes => {
    "" => {
      part => 'Str', # not an expression
      inherit => 'Bool', # true/false
    }
  },
  impl => 'element_content',
);

element 'if-content' => (
  escape_text => 0,
  uses_content => 1,
  attributes => {
    "" => {
      part => 'Str', # not an expression
      inherit => 'Bool',
    }
  },
  impl => 'element_if_content',
);
  
element 'unless-content' => (
  escape_text => 0,
  uses_content => 1,
  attributes => {
    "" => {
      part => 'Str', # not an expression
      inherit => 'Bool',
    }
  },
  impl => 'element_unless_content',
);
  


sub element_snippet {
  my($self, $context, $attr) = @_;
  my $name = $attr -> {"name"} -> [0];

  if($context -> is_mockup) {
    return <<EOS;
<h1>$name</h1>
<p>Snippet with the name "$name"</p>
EOS
  }

  # we want to render the snippet with the current context
  my $project = $context -> get_resource("project");
  if($project) {
    my $snippet = $project -> snippet($name);
    if($snippet) {
      return $snippet -> render($context);
    }
    my $theme = $project -> theme;
    if($theme) {
      $snippet = $theme -> snippet($name);
      if($snippet) {
        return $snippet -> render($context);
      }
    }
  }

  if(!defined($name)) { $name = 'unnamed' }

  my $divClass = "snippet-$name";

  return "<!-- Snippet '$name' not found. -->";
}

sub element_content {
  my($self, $context, $attr) = @_;
  my $name = $attr -> {"part"} -> [0];
  if(!defined($name) || $name eq '') {
    if($context -> has_var('content')) {
      return $context -> get_var('content');
    }
    $name = 'body';
  }

  if($context -> is_mockup) {
    return <<EOP
<h3>$name</h3>

$SAMPLE_CONTENT
EOP
  }

  my $inherit = $attr -> {'inherit'};

  # we want to render the page part with the current context
  # if the current page doesn't have the named part, then we want
  # to go up the current sitemap until we find it.
  my $page = $context -> get_resource("page");
  if($page) {
    my $page_part = $page -> page_part( $name );
    if($inherit) {
      while($page && !$page_part) {
        $page = $page -> parent_page;
        if($page) {
          $page_part = $page -> page_part( $name );
        }
      }
    }

    if($page_part) {
      return $page_part -> render($context);
    }
  }
  return "<!-- Page part '$name' not found. -->";
}

sub has_content_q {
  my($self, $context, $attr) = @_;
  my $name = $attr -> {"part"} -> [0];
  my $has_content = $context -> is_mockup;
  if(!defined($name) || $name eq '') {
    if($context -> has_var('content')) {
      $has_content = 1;
    }
    $name = 'body';
  }

  if(!$has_content) {
    my $inherit = $attr -> {'inherit'};

    my $page = $context -> get_resource("page");
    if($page) {
      my $page_part = $page -> page_part( $name );
      if($inherit) {
        while($page && !$page_part) {
          $page = $page -> parent_page;
          if($page) {
            $page_part = $page -> page_part( $name );
          }
        }
      }

      if($page_part) {
        $has_content = 1;
      }
    }
  }
  return $has_content;
}

sub element_if_content {
  my($self, $context, $attr, $yield) = @_;
  if($self -> has_content_q($context, $attr)) {
    return $yield->();
  }
  return '';
}

sub element_unless_content {
  my($self, $context, $attr, $yield) = @_;
  if(!$self -> has_content_q($context, $attr)) {
    return $yield->();
  }
  return '';
}

1;
