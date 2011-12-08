class BlogCategoriesController < InheritedResources::Base
  skip_before_filter :authenticate_admin!, :only => [:show]
  cache_sweeper :post_sweeper, :only => [:create, :update, :destroy] # don't need this, it's built on observers
  
  def show
    redirect_to_best_friendly_id(blog_category_posts_path(resource.friendly_id)) and return
    google_landing_page('Post')
    add_breadcrumb @google.page_title, :posts_index_path
    google_show_page
    add_breadcrumb @google.page_title, blog_category_posts_path(resource)
    show!
  end
  
  def new
   new!{build_google_resource}
  end
  
  def create
   create!{posts_index_url}
  end
  
  def update
    update!{posts_index_url}
  end
  
  def sort
    generic_sortable(BlogCategory.scoped)
  end
  
  protected
  
  def collection
    if action_name == 'show'
      @collection ||= resource.posts
    else
      super
    end
  end
  
end
