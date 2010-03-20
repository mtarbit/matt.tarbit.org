ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.index     '', :controller=>'blog'
  map.connect   'page/:page', :controller=>'blog'
  map.about     'about', :controller=>'blog', :action=>'about'
  map.archive   'archive', :controller=>'blog', :action=>'archive'
  map.titles    'archive/titles', :controller=>'blog', :action=>'archives_by_title'
  map.search    'search', :controller=>'blog', :action=>'search'
  map.cv        'cv', :controller=>'blog', :action=>'cv'
  map.hobby_games 	'hobby_games', :controller=>'blog', :action=>'hobby_games'
  map.family_games 	'family_games', :controller=>'blog', :action=>'family_games'
  map.tags	    'tag', :controller=>'tag'
  map.tag       'tag/:name', :controller=>'tag', :action=>'read'
  map.rss       'rss', :controller=>'feed', :action=>'rss'
  map.admin		'admin', :controller=>'admin'
  map.librarian	'admin/library', :controller=>'admin', :action=>'library'
  map.library	'book', :controller=>'book'
  map.logout    'logout', :controller=>'admin', :action=>'logout'
  map.new_book  'new/book', :controller=>'book', :action=>'new'
  map.new_entry 'new/:variant', :controller=>'entry', :action=>'new'

  map.date ':y/:m/:d', 
    :controller=>'blog', :action=>'date', :m=>nil, :d=>nil,
    :requirements => { :y=>/(19|20)\d\d/, :m=>/[01]?\d/, :d=>/[0-3]?\d/ }

  map.entry_slug ':y/:m/:d/:slug', 
    :controller=>'entry', :action=>'read',
    :requirements => { :y=>/(19|20)\d\d/, :m=>/[01]?\d/, :d=>/[0-3]?\d/, :slug=>/[a-z0-9._-]+/ }

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  
  # Custom 404 (http://forum.activereload.net/forums/7/topics/169)
  map.notfound '*args', :controller => 'blog', :action => 'notfound'
end
