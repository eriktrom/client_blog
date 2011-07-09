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
  default_scope order('posts.date_of_publish').includes([:google, :blog_category, :tags, :comments, :audios])
  scope :published, where(:publish => true)
  
  
  
  validates_presence_of :author
  validates_presence_of :blog_category_id, :if => Proc.new{new_blog_category_name.blank?}
    
  def create_blog_category_from_name
    create_blog_category(:new_page_title => new_blog_category_name, :description => new_blog_category_description) if new_blog_category_name.present?
  end
  
  # liquid drops
  after_find :get_blog_associated_drops
  def get_blog_associated_drops
    post = self
    [images, videos, audios].each do |objects|
      if objects.any?
        objects.each_with_index do |object, n|
          post.class.class_eval do 
            define_method :"#{object.class.to_s.downcase}_#{n + 1}" do
              object.id
            end
            self.send(:liquid_methods, :"#{object.class.to_s.downcase}_#{n + 1}")
          end
        end
      end
    end
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

# Here is the get_blog_associated_drops method using the version of self from the exmple on page 290 of Rails 3 Way
# the version below is the working version, what I'm curious about is what is happening different when calling it with the commented out lines, eg singleton = ...
# it works the same except when you call self.send(:liquid_methods, :"image_#{n + 1}")
# def get_blog_associated_drops
#   post = self
#   # singleton = class << self; self; end # does not work when calling send(liquid_methods), code from rails 3 way
#   images.each_with_index do |image, n|
#     post.class.class_eval do 
#     # singleton.class_eval do # does not work when calling send(liquid_methods), code from rails 3 way
#       define_method :"image_#{n + 1}" do
#         image.id
#       end
#       self.send(:liquid_methods, :"image_#{n + 1}")
#     end
#   end
# end



# old version 2 of get_blog_associated_drops
# if images.any?
#   images.each_with_index do |image, n|
#     post.class.class_eval do 
#       define_method :"image_#{n + 1}" do
#         image.id
#       end
#       self.send(:liquid_methods, :"image_#{n + 1}")
#     end
#   end
# end
# 
# if videos.any?
#   videos.each_with_index do |video, n|
#     post.class.class_eval do 
#       define_method :"video_#{n + 1}" do
#         video.id
#       end
#       self.send(:liquid_methods, :"video_#{n + 1}")
#     end
#   end
# end
# 
# if audios.any?
#   audios.each_with_index do |audio, n|
#     post.class.class_eval do 
#       define_method :"audio_#{n + 1}" do
#         audio.id
#       end
#       self.send(:liquid_methods, :"audio_#{n + 1}")
#     end
#   end
# end
