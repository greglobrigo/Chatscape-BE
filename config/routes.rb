Rails.application.routes.draw do
  #is there a way to group these routes?

  namespace :users do
  post '/register', to: 'users#register'
  post '/login', to: 'users#login'
  end

  post '/chat', to: 'chats#new'
  delete '/chat', to: 'chats#delete'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
