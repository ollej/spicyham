Spicyham::Application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "omniauth_callbacks"
  }
  as :user do
    get 'users/edit' => 'users/registrations#edit', :as => 'edit_user_registration'
    put 'users/:id' => 'users/registrations#update', :as => 'user_registration'
    delete 'users/:id' => 'users/registrations#update', :as => 'delete_user_registration'
  end

  get "zone", to: "zone#index"
  get "zone/:zone", to: "zone#show", as: "zone_show"
  get "zone/:zone/record/:record", to: "zone#show_record", as: "show_record"
  post "zone/:zone/record", to: "zone#add_record", as: "add_record"
  delete "zone/:zone/record/:record", to: "zone#delete_record", as: "delete_record"
  get "domain", to: "domain#index"
  get "domain/search", to: "domain#search"
  post "domain/create", to: "domain#create"
  get "domain/:domain", to: "domain#show", as: "domain_show"
  get "webredir", to: "webredir#index"
  post "test_api", to: "test_api#create"

  resources :emails, :constraints => {:id => /[^\/]+/}

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  #root 'emails#index'

  get '/health', to: proc { [200, {}, ['success']] }

  authenticated :user do
    root 'emails#index', as: :authenticated_root
  end
  root to: redirect('/users/sign_in')

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
