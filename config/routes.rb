Rails.application.routes.draw do
  
  
  resources :blog_categories, :except => :show do
    post :sort, :on => :collection
  end
  
  resources :posts, :except => [:index, :show] do
    resources :comments, :except => [:show]
  end
  
  scope :path => "/#{Settings.routes.blog}" do
    get '/' => 'posts#index', :as => :posts_index
    get "archive/:year(/:month)" => "posts#archive", :as => :archived_posts#, :constraints => { :year => /\d{4}/, :month => /\d{2}/ }
    get 'tags/:tag' => 'posts#tag', :as => :tagged_posts
    get '/:id' => 'blog_categories#show', :as => :blog_category_posts
    scope :path => '/:blog_category_id' do
      get '/:id' => 'posts#show', :as => :post_show
      get '/:id/preview' => 'posts#preview', :as => :post_preview
    end
  end
  
  
  match '/posts' => redirect("/#{Settings.routes.blog}")
  
end