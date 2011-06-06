Rails.application.routes.draw do
  
  
  resources :blog_categories, :except => :show do
    post :sort, :on => :collection
  end
  
  resources :posts, :except => [:index, :show]
  
  scope :path => "/posts" do
    get '/' => 'posts#index', :as => :posts_index
    get '/:id' => 'blog_categories#show', :as => :blog_category_posts
    scope :path => '/:blog_category_id' do
      get '/:id' => 'posts#show', :as => :post_show
      get '/:id/preview' => 'posts#preview', :as => :post_preview
    end
  end
  


  # resources :categories, :path => "/#{Settings.routes.blog}" do
  #   post :sort, :on => :collection
  # end
  # scope :path => "/#{Settings.routes.blog}/:category_id" do
  #   get '/:id' => 'posts#show', :as => :category_post
  #   get '/:id/preview' => 'posts#preview', :as => :category_post_preview
  # end
  
end