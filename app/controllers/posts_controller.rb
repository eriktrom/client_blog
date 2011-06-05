class PostsController < InheritedResources::Base
  skip_before_filter :authenticate_admin!, :only => [:index, :show]
  custom_actions :resource => :preview
  
  def index
    google_landing_page
    add_breadcrumb @google.page_title, :collection_path
    index!
  end
  
end
