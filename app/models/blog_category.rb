class BlogCategory < ActiveRecord::Base
  has_many :posts
  include Listable
  include GoogleableCreatedThroughAssociation
  
  default_scope order('blog_categories.position')
  
end
