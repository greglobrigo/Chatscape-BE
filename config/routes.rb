Rails.application.routes.draw do

  post '/chat', to: 'chats#new'
  delete '/chat', to: 'chats#delete'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
