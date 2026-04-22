Spicyham::Application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "omniauth_callbacks"
  }
  as :user do
    get 'users/edit', to: 'users/registrations#edit', as: 'edit_user_registration'
    put 'users/:id', to: 'users/registrations#update', as: 'user_registration'
    delete 'users/:id', to: 'users/registrations#destroy', as: 'delete_user_registration'
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

  resources :emails, only: [:index, :create, :destroy], constraints: { id: /[^\/]+/ }

  get '/up', to: proc { [200, {}, ['success']] }
  get '/home', to: 'pages#home', as: :home

  authenticated :user do
    root 'emails#index', as: :authenticated_root
  end
  root 'pages#home'
end
