Rails.application.routes.draw do
  # is there a way to group these routes?

  namespace :users do
    post '/register', to: 'users#register'
    post '/login', to: 'users#login'
    post '/search-users-all-or-direct', to: 'users#search_users_all_or_direct'
    post '/search-users-group', to: 'users#search_users_group'
    post '/search-users-public', to: 'users#search_users_public'
    post '/get-profile', to: 'users#get_profile'
  end

  namespace :chats do
    post '/public-or-group', to: 'chats#create_public_or_group'
    post '/create-or-retrieve', to: 'chats#create_or_retrieve'
    delete '/', to: 'chats#delete'
    post '/archive', to: 'chats#archive_chat'
  end

  namespace :messages do
    post '/send', to: 'messages#send_message'
    get '/get', to: 'messages#get_messages'
  end

  namespace :chatmembers do
    post '/add', to: 'chatmembers#add'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
