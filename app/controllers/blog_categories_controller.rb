class BlogCategoriesController < InheritedResources::Base
  skip_before_filter :authenticate_admin!, :only => [:show]
  
  def index
    google_landing_page
    index!
  end
  
  def show
    redirect_to_best_friendly_id(resource_url(resource.friendly_id)) and return
    @posts = resource.posts
    google_show_page
    show!
  end
  
  def new
   new!{build_google_resource}
  end
  
  def create
   create!{posts_url}
  end
  
  def update
    update!{posts_url}
  end
  
  def sort
    generic_sortable(BlogCategory.scoped)
  end
  
end
