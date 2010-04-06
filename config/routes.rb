ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  map.index     '', :controller=>'blog'
  map.about     'about', :controller=>'blog', :action=>'about'
  map.archive   'archive', :controller=>'blog', :action=>'archive'
  map.titles    'archive/titles', :controller=>'blog', :action=>'archives_by_title'
  map.search    'search', :controller=>'blog', :action=>'search'
  map.tags	    'tag', :controller=>'tag'
  map.tag       'tag/:name', :controller=>'tag', :action=>'read'
  map.rss       'rss', :controller=>'feed', :action=>'rss'

  map.admin		  'admin', :controller=>'admin'
  map.comments	'admin/comments', :controller=>'comment'
  map.librarian	'admin/library', :controller=>'admin', :action=>'library'
  map.library	  'book', :controller=>'book'
  map.logout    'logout', :controller=>'admin', :action=>'logout'
  map.new_book  'new/book', :controller=>'book', :action=>'new'
  map.new_entry 'new/:variant', :controller=>'entry', :action=>'new'

  map.connect   'page/:page', :controller=>'blog'
  map.connect 	'hobby_games', :controller=>'blog', :action=>'hobby_games'
  map.connect 	'family_games', :controller=>'blog', :action=>'family_games'
  map.cv        'cv', :controller=>'blog', :action=>'cv'

  map.date ':y/:m/:d', 
    :controller=>'blog', :action=>'date', :m=>nil, :d=>nil,
    :requirements => { :y=>/(19|20)\d\d/, :m=>/[01]?\d/, :d=>/[0-3]?\d/ }

  map.entry_slug ':y/:m/:d/:slug', 
    :controller=>'entry', :action=>'read',
    :requirements => { :y=>/(19|20)\d\d/, :m=>/[01]?\d/, :d=>/[0-3]?\d/, :slug=>/[a-z0-9._-]+/ }

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'

end
