class CommentsController < InheritedResources::Base
  actions :all, :except => [:index, :show]
  belongs_to :post, :polymorphic => true
  
  def new
    @comment = Comment.new(:commentable_type => parent_class, :commentable_id => parent, :parent_id => params[:parent_id])
    new!
  end
  
  def create
    create! {:back}
  end
  
  def update
    update! {:back}
  end
  
  def destroy
    destroy! {:back}
  end
  
end
