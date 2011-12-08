class PostsController < InheritedResources::Base
  skip_before_filter :authenticate_admin!, :only => [:index, :show, :preview, :archive, :tag]
  custom_actions :resource => :preview, :collection => [:tag, :archive]
  respond_to :html, :js, :atom
  cache_sweeper :post_sweeper, :only => [:create, :update, :destroy] # don't need this, it's built on observers
  
  def index
    google_landing_page
    add_breadcrumb @google.page_title, :posts_index_path
    index!
  end
  
  def tag
    self.class.class_eval do
      define_method :collection do
        posts_collection.tagged_with(params[:tag], :any => true)
      end
    end
    google_landing_page('Tags')
    add_breadcrumb "#{Google.where(:googleable_type => 'Post', :googleable_id => nil).first.page_title}", :posts_index_path
    add_breadcrumb "#{@google.page_title} '#{params[:tag]}'", tagged_posts_path(params[:tag])
    tag!{render 'posts/index' and return}
  end
  
  def archive
    self.class.class_eval do
      define_method :collection do
        Post.get_requested_archive(posts_collection, {:year => params[:year], :month => params[:month]})
      end
    end
    google_landing_page('Archive')
    breadcrumb_path = params[:month].present? ? {:year => params[:year], :month => params[:month]} : params[:year]
    breadcrumb_path_date = params[:month].present? ? DateTime.new(params[:year].to_i, params[:month].to_i).to_s(:breadcrumb_month_and_year) : DateTime.new(params[:year].to_i).to_s(:year)
    add_breadcrumb "#{Google.where(:googleable_type => 'Post', :googleable_id => nil).first.page_title}", :posts_index_path
    add_breadcrumb "#{@google.page_title} for #{breadcrumb_path_date}", archived_posts_path(breadcrumb_path)
    archive!{render 'posts/index' and return}
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
    posts_collection
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
