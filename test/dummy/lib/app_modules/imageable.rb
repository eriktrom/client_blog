module Imageable
  
  extend ActiveSupport::Concern

  included do
    has_many :images, :as => :imageable
    accepts_nested_attributes_for :images, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  end

  module ClassMethods
    
  end

  module InstanceMethods
    
  end
  
end