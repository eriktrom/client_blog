module FormHelper

  def cancel_b(urlpath = '#', cancel_b_text = 'Cancel', args = {:class => 'cancel button'})
    css_class = args[:class]
    raw("#{link_to cancel_b_text, urlpath, :class => css_class}")
  end
  
  def cancel_b_function(replaced_tag, partial, *args)
    button_to_function("Cancel", ("cancel_button(\"##{replaced_tag}\", \"#{raw escape_javascript(render partial, *args)}\")"), :class => "close cancel")
  end

  # def close_b_function(removed_tag)
  #   button_to_function "Close", :class => "close cancel" do |page| page.remove "#{removed_tag}" end
  # end
  
  def link_to_remove_fields(name, f)
		f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
	end
	
	def link_to_add_fields(name, f, association)
		new_object = f.object.class.reflect_on_association(association).klass.new
		fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
			render("#{association.to_s}/" + association.to_s.singularize + "_fields", :f => builder)
		end
		link_to_function(name, ("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
	end
	
	def form_is(what)
		request.params[:form_is] == what
	end
	
	def user_slug_fields(f, human_name, human_attribute)
	 render(:partial => 'shared/user_slug', :locals => {:f => f, :human_name => human_name, :human_attribute => human_attribute})
	end
	
	
end
