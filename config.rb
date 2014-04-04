set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'
set :fonts_dir, 'assets/fonts'

activate :syntax
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true

activate :blog do |blog|
  blog.prefix = "blog"
  blog.layout = "blog"
  blog.permalink = ":year/:month/:title.html"
end
page "/blog/feed.xml", :layout => false

activate :asset_hash
