Rails.application.routes.draw do
  
  resources :posts do
    get :preview, :on => :member
  end
  
  # resources :categories, :path => "/#{Settings.routes.blog}" do
  #   post :sort, :on => :collection
  # end
  # scope :path => "/#{Settings.routes.blog}/:category_id" do
  #   get '/:id' => 'posts#show', :as => :category_post
  #   get '/:id/preview' => 'posts#preview', :as => :category_post_preview
  # end
  
end