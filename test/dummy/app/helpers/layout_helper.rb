module LayoutHelper

  def screencasts_links
    admin_area do
      link_to 'Learn about your site through screencasts.', screencasts_path
    end
  end
        
  def og_title(page_title, heading_title = page_title, desc = nil, show_title = true) #returns same title, in two places
    content_for(:title) { page_title.to_s }
    content_for(:h1_title) { heading_title.to_s }
    content_for(:meta_desc) { desc.to_s }
    @show_title = show_title
  end
  
  def title(show_title = true, meta_title = @google.meta_title, page_title = @google.page_title || meta_title, meta_desc = @google.meta_desc || nil) #returns custom slug titles
    content_for(:title) { meta_title.to_s } 
    content_for(:h1_title) { page_title.to_s }
    content_for(:meta_desc) { meta_desc.to_s }
    @show_title = show_title
    @title_is_defined = true
  end
  
  def hide_title?
    !@show_title
  end
  
  def title_is_defined?
    defined?(@title_is_defined) ? true : false
  end

  def canonical_link_tag(url_options = {})
    # this is the actual helper... the canonical_link_tag_path is a shortcut for calling content_for :canonical_link_tag_path, but using the syntax like title
    # only use this version when not rendering inside the default layout(application.html.haml) aka, for ajax called pages
    tag(
      "link",
      "rel"   => "canonical",
      "href"  => url_options.is_a?(Hash) ? url_for(url_options.merge(:only_path => false)) : url_options
    )
  end

  def canonical_link_tag_url(absolute_url)
    # this is simply a shortcut for content_for :canonical_link_tag_path, use it like - canonical_link_tag_path target_path(optional_object_ids)
    content_for(:canonical_link_tag_url) {canonical_link_tag(absolute_url)}
  end
  
  # def ss(*args)
  #   content_for(:inline_css_link_tag) { stylesheet_link_tag(*args) }
  # end
  
  def js(*args)
    content_for(:include_js) { javascript_include_tag(*args) }
  end
  
  def env_js(on = true)
    if Rails.env.development? && on == true
      javascript_include_tag 'jquery.min', 'jquery-ui.min', 'jquery.tools', 'flowplayer-3.2.6.min', 'rails', 'jquery.equalheights', 'noConflict', 'application'
    else
      javascript_include_tag 'base_packaged'
    end
  end

  def body_class(body_class)
    content_for(:body_class) { body_class }
  end
  
  def meta_desc(meta_desc)
    content_for(:meta_desc) { meta_desc }
  end
  
  def meta_keywords(meta_keywords)
    content_for(:meta_keywords) { meta_keywords }
  end
  
  def notice_and_alert
    x = content_tag(:div, notice, :class => 'notice') if notice.present?
    x = content_tag(:div, alert, :class => 'alert') if alert.present?
    x
  end

  def ajax_flash(model, special_message = nil)
    if special_message == nil
      x = content_tag(:div, notice_and_alert, :id => "ajax_flash_#{model.id}")
    else
      x = content_tag(:p, special_message, :id => "ajax_flash_#{model.id}", :class => 'notice')
    end
    x
  end
  
  def meta_content
    {'http-equiv' => "content-type", :content => "text/html; charset=UTF-8"}
  end

  def admin_area(args = {:class => 'admin'}, &block)
    css_class = args[:class]
    content_tag(:div, :class => css_class, &block) if admin?
  end
  
  def superadmin_area(&block)
    content_tag(:div, :class => "admin", &block) if superadmin?
  end

  def admin_and_flash_area(&block)
    content_tag(:div, :id => 'flash_area', &block) if admin? || notice.present? || alert.present?
  end
  
  def breadcrumb_area(&block)
    content_tag(:h1, :id => 'breadcrumbs_div', &block) unless homepage?
  end
   
  def parent_layout(layout)
    @_content_for[:layout] = self.output_buffer
    self.output_buffer = render(:file => "layouts/#{layout}")
  end
  
  def web_fonts(css_string)
    stylesheet_link_tag "http://f.fontdeck.com/s/css/#{css_string}/#{Settings.host}/#{Settings.fontdeck_website_name_id}.css"
  end
  
  def google_analytics(ga_id = 'UA-16274695-X')
    if Rails.env.production? && !admin?
      javascript_tag do
        %( var _gaq = _gaq || []; _gaq.push(['_setAccount', '#{ga_id}']); _gaq.push(['_trackPageview']); (function() {var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true; ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'; (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);})(); )
      end
    end
  end
  
  def dd_belatedpng
    x = raw(%q(
      <!--[if lt IE 7 ]>
        <script src="/javascripts/dd_belatedpng.js"></script>
        <script>DD_belatedPNG.fix("img, .png_bg");</script>
      <![endif]-->
    ))
    x
  end
  
  def meta_location(city, state, state_code, zip, lat, lng, country = 'United States (usa)')
    x = raw(%(
      <meta name="city" content="#{city}">
      <meta name="country" content="#{country}">
      <meta name="state" content="#{state}">
      <meta name="zipcode" content="#{zip}">
      <meta name="geo.position" content="#{lat};#{lng}">
      <meta name="geo.placename" content="#{city}, #{state_code}">
      <meta name="geo.region" content="US-#{state_code}">
      <meta name="icbm" content="#{lat};#{lng}">
    ))
    x
  end
  
  def admin_resource(link_text, path)
    content_for :page_title_extras do
      admin_area(:class => 'admin_header admin') do
        link_to link_text, path
      end
    end
  end
  
  def page_title_admin_area(&block)
    content_for :page_title_extras do
      admin_area(:class => 'admin_header admin', &block)
    end
  end
  
  def cached_area(fragment_name, &block)
    if admin?
      cache "admin_#{fragment_name}" do
        yield
      end
    else
      cache fragment_name do
        yield
      end
    end
  end
  
  def conditional_page_title(&block)
    unless content_for(:h1_title).blank? || hide_title?
      content_tag(:div, :id => 'page_title', :class => ('with_sidebar' if content_for?(:sidebar)), &block)
    end
  end
  
  def while_admin_css
    'while_admin' if admin?
  end
  
  def image_alt(image)
   image.alt.present? ? image.alt : image.title
  end
  
  def md(text)
    if !text.nil?
      RDiscount.new(text).to_html.html_safe
    else
      text
    end
  end
  
end
