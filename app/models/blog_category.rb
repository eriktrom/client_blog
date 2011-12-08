class BlogCategory < ActiveRecord::Base
  has_many :posts
  include Listable
  include GoogleableCreatedThroughAssociation
  
  default_scope order('blog_categories.position').includes(:google, {:posts => :google})
  
  def self.for_sidebar
    Rails.cache.fetch 'BlogCategory.for_sidebar' do
      BlogCategory.scoped.all
    end
  end
    
end
