Rails.application.routes.draw do
  # is there a way to group these routes?

  namespace :users do
    post '/register', to: 'users#register'
    post '/login', to: 'users#login'
  end

  namespace :chats do
    post '/', to: 'chats#new'
    delete '/', to: 'chats#delete'
  end

  namespace :messages do
    post '/send', to: 'messages#send_message'
    get '/get', to: 'messages#get_messages'
  end

  namespace :chatmembers do
    get '/test', to: 'chatmembers#test'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
