class BlogCategory < ActiveRecord::Base
  has_many :posts
  include Googleable
  include Listable
  
  default_scope order('blog_categories.position')
  
  # validates_presence_of :name
  # validates_uniqueness_of :name
end
