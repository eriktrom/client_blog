class Post < ActiveRecord::Base
  belongs_to :category
  attr_accessor :new_category_name
  before_save :create_category_from_name
  include Googleable
  default_scope order('posts.date_of_publish').includes([:google])
  scope :published, where(:publish => true)
  
  validates_presence_of :author
  validates_presence_of :category, :if => Proc.new{new_category_name.blank?}
  
  private
  
  def create_category_from_name
    create_category(:name => new_category_name, :google_attributes => {:meta_title => new_category_name, :page_title => new_category_name, :meta_desc => new_category_name}) if new_category_name.present?
  end
  
end


# FOR LYNNF
# -- add into _form.html.haml

# .field.select.required
#   = f.label :media_id, "<abbr title='required'>*</abbr>Media".html_safe, :class => 'select required'
#   = f.collection_select :media_id, Media.all, :id, :name, {:prompt => "Select a media type"}, {:class => 'select required'}
#   or create one:
#   = f.text_field :new_media_name, :class => 'string required'

# -- add into post.rb