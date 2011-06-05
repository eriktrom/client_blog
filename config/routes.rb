Rails.application.routes.draw do
  
  resources :posts do
    get :preview, :on => :member
  end
  
end