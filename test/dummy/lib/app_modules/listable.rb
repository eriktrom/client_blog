module Listable
  
  extend ActiveSupport::Concern

  included do
  	acts_as_list
  	before_create :increment_positions_on_all_items
  	after_create :assume_top_position
  end

  module ClassMethods
    
  end

  module InstanceMethods
    
  end
  
end