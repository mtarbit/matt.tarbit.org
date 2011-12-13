MattTarbitOrg::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  root          :to => 'blog#index', :as => :index

  match         'about' => 'blog#about', :as => :about
  match         'archive' => 'blog#archive', :as => :archive
  match         'archive/titles' => 'blog#archives_by_title', :as => :titles
  match         'search' => 'blog#search', :as => :search
  match         'tag' => 'tag#index', :as => :tags
  match         'tag/:name' => 'tag#read', :as => :tag
  match         'rss' => 'feed#rss', :as => :rss

  match         'admin' => 'admin#index', :as => :admin
  match         'admin/comments' => 'comment#index', :as => :comments
  match         'admin/library' => 'admin#library', :as => :librarian
  match         'book' => 'book#index', :as => :library
  match         'logout' => 'admin#logout', :as => :logout
  match         'new/book' => 'book#new', :as => :new_book
  match         'new/:variant' => 'entry#new', :as => :new_entry

  match         'hobby[-_]games' => 'blog#hobby_games'
  match         'family[-_]games' => 'blog#family_games'
  match         'cv' => 'blog#cv'

  match ':y(/:m(/:d))' => 'blog#date', :as => :date, 
    :constraints => { :y=>/(19|20)\d\d/, :m=>/[01]?\d/, :d=>/[0-3]?\d/ }

  match ':y/:m/:d/:slug' => 'entry#read', :as => :entry_slug,
    :constraints => { :y=>/(19|20)\d\d/, :m=>/[01]?\d/, :d=>/[0-3]?\d/, :slug=>/[a-z0-9._-]+/ }

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'

end
