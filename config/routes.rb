Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  namespace :users do
    post '/register', to: 'users#register'
    post '/login', to: 'users#login'
    post '/search-users-all-or-direct', to: 'users#search_users_all_or_direct'
    post '/search-users-group', to: 'users#search_users_group'
    post '/search-users-public', to: 'users#search_users_public'
    post '/get-profile', to: 'users#get_profile'
    post '/change-password', to: 'users#change_password'
    post '/confirm-email', to: 'users#confirm_email'
    post '/resend-token', to: 'users#resend_token'
    post '/forgot-password', to: 'users#forgot_password'
    post '/confirm-forgotten-password', to: 'users#confirm_forgot_password'
    post '/admin-register', to: 'users#admin_register'
    post '/resend-token', to: 'users#resend_token'
    post '/validate', to: 'users#validate'
    post '/edit-avatar', to: 'users#edit_avatar'
    post '/delete-user', to: 'users#delete_user'
  end

  namespace :chats do
    post '/public-or-group', to: 'chats#create_public_or_group'
    post '/create-or-retrieve', to: 'chats#create_or_retrieve'
    post '/search-public', to: 'chats#search_public'
    post '/join-public', to: 'chats#join_public'
  end

  namespace :messages do
    post '/send', to: 'messages#send_message'
    post '/get', to: 'messages#get_messages'
    post '/chats-and-messages', to: 'messages#get_chats_and_messages'
    post '/delete', to: 'messages#delete_message'
  end

  namespace :chatmembers do
    post '/add', to: 'chatmembers#add'
    post '/leave', to: 'chatmembers#leave'
    post '/archive', to: 'chatmembers#archive_chat'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
