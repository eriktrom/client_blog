class Post < ActiveRecord::Base
  belongs_to :blog_category
  has_many :comments, :as => :commentable
  attr_accessor :new_blog_category_name, :new_blog_category_description
  include Imageable
  include Videoable
  include Audioable
  include Googleable
  acts_as_taggable
  # acts_as_taggable_on :medias
  before_save :create_blog_category_from_name
  default_scope order('posts.date_of_publish DESC')#.includes(:google, :blog_category, :audios, :images)
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
            define_method :"#{object.class.to_s.downcase}_#{object.id}" do
              object.id
            end
            self.send(:liquid_methods, :"#{object.class.to_s.downcase}_#{object.id}")
          end
        end
      end
    end
  end
  
  # archive blog posts by date
  def self.get_requested_archive(collection, date)
    year, month = date[:year], date[:month]
    if month.present?
      requested_archive = Date.new(year.to_i, month.to_i)
      archive_range = requested_archive.beginning_of_month..requested_archive.end_of_month
    else
      requested_archive = Date.new(year.to_i)
      archive_range = requested_archive.beginning_of_year..requested_archive.end_of_year
    end
    collection.where(:date_of_publish => archive_range)
  end
  
  def self.cached_requested_archive_count(collection, date)
    Rails.cache.fetch "Post.cached_requested_archive_count_#{self.my_cache_key(date)}" do
      self.get_requested_archive(collection, date).count
    end
  end
  
  def self.cached_requested_archive(collection, date)
    Rails.cache.fetch "Post.cached_requested_archive_#{self.my_cache_key(date)}" do
      self.get_requested_archive(collection, date).all
    end
  end
  
  def self.my_cache_key(date)
    year, month = date[:year], date[:month]
    month.present? ? "#{month}_#{year}" : "#{year}"
  end
  
  def self.cache_delete_matched_archives
    Rails.cache.delete_matched(%r{Post.cached_requested_archive_.+})
  end
  
  # create the menu of months with posts for the current year
  def self.months_with_posts
    self.select('id, date_of_publish, publish, blog_category_id').published.collect{|post| {:month_number => post.date_of_publish.to_s(:month_number), :month_name => post.date_of_publish.to_s(:month_name), :year => post.date_of_publish.to_s(:year)} }
  end
  
  def self.uniq_months_with_posts
    Rails.cache.fetch 'Post.uniq_months_with_posts' do
      self.months_with_posts.uniq
    end
  end
  
  def self.years_with_posts
    self.select('id, date_of_publish, publish, blog_category_id').published.collect{|post| post.date_of_publish.to_s(:year) }
  end
  
  def self.uniq_years_with_posts
    Rails.cache.fetch 'Post.uniq_years_with_posts' do
      self.years_with_posts.uniq
    end
  end
  
  # create the menu of years with posts
  
  
  # only posts that are published are publicly readable
  def self.published_collection(is_admin, collection)
    if is_admin
      collection.scoped
    else
      collection.published
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
