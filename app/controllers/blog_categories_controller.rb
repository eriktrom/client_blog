class BlogCategoriesController < InheritedResources::Base
  skip_before_filter :authenticate_admin!, :only => [:show]
  
  def show
    redirect_to_best_friendly_id(blog_category_posts_path(resource.friendly_id)) and return
    @posts = resource.posts
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
  
end
