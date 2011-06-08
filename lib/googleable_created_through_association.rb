module GoogleableCreatedThroughAssociation
  
  extend ActiveSupport::Concern

  included do
    has_one :google, :as => :googleable, :dependent => :destroy
    attr_accessor :new_page_title
    has_friendly_id :new_or_present_page_title, :use_slug => true
    before_create :create_google_from_new_page_title
    before_update :auto_save_google
    accepts_nested_attributes_for :google, :allow_destroy => true
    validates_presence_of :new_page_title, :on => :create
    validates_presence_of :page_title, :on => :update
  end

  module ClassMethods
    
  end
  
  module InstanceMethods
    def page_title=(page_title)
      google.attributes = {:page_title => page_title}
    end

    def page_title
      google.page_title
    end

    def create_google_from_new_page_title
      create_google(:page_title => new_page_title, :meta_title => new_page_title, :meta_desc => description)
    end

    def new_or_present_page_title
      new_page_title.present? ? new_page_title : page_title
    end

    def auto_save_google
      google.attributes = {:meta_title => google.meta_title.present? ? google.meta_title : page_title, :meta_desc => google.meta_desc.present? ? google.meta_desc : description}
    end
  end
  
end