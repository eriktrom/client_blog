class PostsController < InheritedResources::Base
  skip_before_filter :authenticate_admin!, :only => [:index, :show, :preview]
  custom_actions :resource => :preview, :collection => :tag
  respond_to :html, :js, :atom
  
  def index
    google_landing_page
    add_breadcrumb @google.page_title, :posts_index_path
    @tags = collection.tag_counts_on(:tags)
    index!
  end
  
  def tag
    @tag = params[:tag]
    @tags = collection.tag_counts_on(:tags)
    @posts = collection.tagged_with(@tag, :any => true)
    tag!
  end
  
  def show
    if !resource.publish?
      flash[:notice] = 'This post is not published! You are viewing an identical preview.'
      redirect_to post_preview_url(resource.blog_category.friendly_id, resource.friendly_id) and return
    end
    redirect_to_best_friendly_id(post_show_url(resource.blog_category.friendly_id, resource.friendly_id), resource.blog_category, true) and return
    setup_base_for_resource(post_show_path(resource.blog_category, resource))
    show!
  end
  
  def preview
    redirect_to_best_friendly_id(post_preview_url(resource.blog_category.friendly_id, resource.friendly_id), resource.blog_category, true) and return
    setup_base_for_resource(post_preview_path(resource.blog_category, resource))
    preview!{render 'posts/show' and return}
  end
  
  def new
   new!{build_google_resource}
  end
  
  def create
    create! do |success, failure|
      success.html do
        if params[:commit] == 'Submit and Return'
          redirect_to edit_resource_url, :notice => 'Your assets have been saved. You may now add them to the appropriate text areas.'
        else
          redirect_to post_preview_url(resource.blog_category, resource), :notice => 'Your post has been created but is not yet live on the web! Please make any necessary changes and then click publish below.'
        end
      end
      failure.html{super}
    end
  end
  
  def update
    if params[:publish] == '1'
      resource.update_attributes(:publish => true, :date_of_publish => Time.zone.now)
      redirect_to post_show_url(resource.blog_category, resource), :notice => 'Your post has now been published. Good job!'
    else
      update! do |success, failure|
        success.html do
          if params[:commit] == 'Submit and Return'
            redirect_to :back, :notice => 'Your assets have been saved. You may now add them to the appropriate text areas.'
          else
            redirect_to post_show_url(resource.blog_category, resource), :notice => 'The article has been updated'
          end
        end
      end
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
  
  private
  
  def setup_base_for_resource(custom_page_path)
    google_landing_page
    add_breadcrumb @google.page_title, :posts_index_path
    google_show_page('BlogCategory', resource.blog_category)
    add_breadcrumb @google.page_title, blog_category_posts_path(resource.blog_category)
    google_show_page
    add_breadcrumb @google.page_title, custom_page_path
    # @comment = Comment.new(:commentable_type => resource_class, :commentable_id => resource.id)
  end
  
  def collection_path
    posts_index_path
  end
  
end
