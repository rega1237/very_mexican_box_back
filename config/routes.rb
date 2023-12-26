Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :subscriptions, only: %i[show create update]
  resources :cards, only: %i[index show create destroy update]

  get 'users/:id/subscriptions', to: 'users#user_subscriptions'
  
  get 'users/:id', to: 'users#show'

  put 'subscriptions/:id/cancel_stripe_subscription', to: 'subscriptions#cancel_stripe_subscription'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
