Rails.application.routes.draw do
  devise_for :users, path: '', path_names:
  {
    sign_in: 'login',
    sign_out: 'logout',
    registrations: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  post '/chat', to: 'chats#new'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
