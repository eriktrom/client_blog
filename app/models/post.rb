class Post < ActiveRecord::Base
  belongs_to :blog_category
  has_many :comments, :as => :commentable
  attr_accessor :new_blog_category_name, :new_blog_category_description
  include Imageable
  include Videoable
  include Audioable
  include Googleable
  acts_as_taggable
  acts_as_taggable_on :medias
  before_save :create_blog_category_from_name
  default_scope order('posts.date_of_publish').includes([:google, :blog_category, :tags])
  scope :published, where(:publish => true)
  
  validates_presence_of :author
  validates_presence_of :blog_category_id, :if => Proc.new{new_blog_category_name.blank?}
    
  def create_blog_category_from_name
    create_blog_category(:new_page_title => new_blog_category_name, :description => new_blog_category_description) if new_blog_category_name.present?
  end
  
end


# FOR LYNNF
# -- add into _form.html.haml

# .field.select.required
#   = f.label :blog_media_id, "<abbr title='required'>*</abbr>Media".html_safe, :class => 'select required'
#   = f.collection_select :blog_media_id, BlogMedia.all, :id, :name, {:prompt => "Select a media type"}, {:class => 'select required'}
#   or create one:
#   = f.text_field :new_blog_media_name, :class => 'string required'

# -- add into post.rb