$(function() {
  $("#ookook-apparatus-body").hide();
  $("#ookook-apparatus-handle").click(function() {
    $("#ookook-apparatus-body").toggle(300);
  });

  // we want to go through all of the paragraphs under #ookook-rendering
  // and add a counter
  // we reset the counter on <h1> tags
  var pcounter = 1;
  $("#ookook-rendering p").each(function(idx, el) {
    if($(el).prev().prop("tagName") == "H1") {
      pcounter = 1;
    }
    $(el).prepend("<div class='paragraph-counter'><span>" + pcounter + "</span></div>");
    pcounter += 1;
  });
});
