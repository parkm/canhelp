Rails.application.routes.draw do
  root to: 'index#index'
  namespace :api do
    namespace :internal do
      resources :plugins
      post 'plugins/execute', to: 'plugins#execute'
    end
  end
end
