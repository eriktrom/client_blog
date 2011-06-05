class Post < ActiveRecord::Base
  belongs_to :blog_category
  attr_accessor :new_blog_category_name, :new_blog_category_description
  before_save :create_blog_category_from_name
  include Googleable
  default_scope order('posts.date_of_publish').includes([:google])
  scope :published, where(:publish => true)
  
  validates_presence_of :author
  validates_presence_of :blog_category, :if => Proc.new{new_blog_category_name.blank?}
  
  private
  
  def create_blog_category_from_name
    create_blog_category(:name => new_blog_category_name, :google_attributes => {:meta_title => new_blog_category_name, :page_title => new_blog_category_name, :meta_desc => new_blog_category_description}) if new_blog_category_name.present?
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