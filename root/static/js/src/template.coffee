ookook.namespace 'template', (template) ->
  t = (s) -> 
    (d) -> _.template(s, d, {variable: 'data'})

  _.templateSettings =
    interpolate: /\{\{(.*?)\}\}/g
    escape: /\{\[(.*?)\]\}/g
    evaluate: /\[\[(.*?)\]\]/g

  template.namespace 'factsheet', (fs) ->
    fs.Project = t """
      <h2>{{ data.title[0] }}</h2>
      <p class='type'>Project</p>
      <p>{{ data.description[0] }}</p>
    """
    fs.Board = t """
      <h2>{{ data.title[0] }}</h2>
      <p class='type'>Editorial Board</p>
      [[ if(data.description != null && data.description.length > 0) { ]]
      <p>{{ data.description[0] }}</p>
      [[ } ]]
    """
    fs.SitemapPage = t """
      <h2>{{ data.title[0] }}</h2>
      <p class='type'>Sitemap Page</p>
      [[ if(data.page != null && data.page.length > 0) { ]]
        <p>Linked to: {{ data.page[0] }}</p>
      [[ } ]]
      [[ if(data.description != null && data.description.length > 0) { ]]
        <p>{{ data.description[0] }}</p>
      [[ } ]]
    """
