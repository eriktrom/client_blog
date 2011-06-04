module ControllerHelper
  
  def generic_sortable(modelname) #make sure modelname is in singular and camelized
    if admin?
      @sortables = modelname
      @sortables.each do |sortable|
        sortable.position = params[:sortable].index(sortable.id.to_s) + 1
        sortable.save(:validate => false)
      end
      render :nothing => true
    else
      render :nothing => true
    end
  end
  
  def homepage?
    request.url == root_url
  end
  
  def redirect_to_best_friendly_id(friendly_url = resource_url, parent = nil, nested = false)
    if request.url != friendly_url
      if nested == true
        if !resource.friendly_id_status.best?
          redirect_to friendly_url, :status => :moved_permanently
        elsif !parent.friendly_id_status.best?
          redirect_to friendly_url, :status => :moved_permanently
        end
      else
        if !resource.friendly_id_status.best?
          redirect_to friendly_url, :status => :moved_permanently
        end
      end
    end
  end
  
  def google_show_page(resource_class = resource_class, resource = resource)
    @google = Google.where(:googleable_type => resource_class, :googleable_id => resource.id).first
  end
  
  def google_landing_page(resource_class = controller_name.classify.constantize.to_s)
    @google = Google.find_or_create_by_googleable_type(resource_class)
  end
  
  def build_google_resource(resource_class = resource_class, resource = resource)
    resource.build_google(:googleable_type => resource_class, :googleable_id => resource.id)
  end
  
  protected
  
  def true_for_these_admins(*args)
    case current_admin.username
    when *args
      true
    else
      false
    end
  end
  
  def allow_devise_login?
    controller_path == 'devise/sessions' ? true : false
  end
  
  def allow_devise_registration?
    if Rails.env.development?
      controller_path == 'devise/registrations' ? true : false
    else
      false
    end
  end
  
  def allow_devise_password_change?
    controller_path == 'devise/passwords' ? true : false
  end
  
end