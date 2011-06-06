class PostsController < InheritedResources::Base
  skip_before_filter :authenticate_admin!, :only => [:index, :show]
  custom_actions :resource => :preview
  
  def index
    google_landing_page
    add_breadcrumb @google.page_title, :collection_path
    index!
  end
  
  def show
    if !resource.publish?
      flash[:notice] = 'This post is not published! You are viewing an identical preview.'
      redirect_to preview_resource_path and return
    end
    redirect_to_best_friendly_id(resource_url(resource.friendly_id)) and return
    google_show_page
    show!
  end
  
  def preview
    redirect_to_best_friendly_id(post_preview_url(resource.friendly_id)) and return
    google_show_page
    preview!
  end
  
  def new
   new!{build_google_resource}
  end
  
  def create
    create! do |success, failure|
      success.html{redirect_to post_preview_url(resource), :notice => 'Your post has been created but is not yet live on the web! Please make any necessary changes and then click publish below.'}
      failure.html{super}
    end
  end
  
  def update
    if params[:publish] == '1'
      resource.update_attributes(:publish => true, :date_of_publish => Time.zone.now)
      redirect_to resource_url, :notice => 'Your post has now been published. Good job!'
    else
      update!
    end
  end
  
  protected
  
  def collection
    if admin?
      super.scoped
    else
      super.published
    end
  end
  
end
