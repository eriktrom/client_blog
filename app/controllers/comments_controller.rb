class CommentsController < InheritedResources::Base
  skip_before_filter :authenticate_admin!, :except => [:destroy]
  
  actions :all, :except => [:index, :show]
  belongs_to :post, :polymorphic => true
  respond_to :html, :js
  
  def new
    @comment = Comment.new(:commentable_type => parent_class, :commentable_id => parent, :parent_id => params[:parent_id])
    @reply_to_comment = Comment.find(params[:parent_id])
    new!
  end
  
  def create
    create! do |success, failure|
      success.js do
        @parent_id = resource.parent_id ? resource.parent_id : ''
      end
      success.html {redirect_to :back}
      failure.html {super}
      failure.js {super}
    end
  end
  
  def update
    update! {:back}
  end
  
  def destroy
    destroy! {:back}
  end
  
end
