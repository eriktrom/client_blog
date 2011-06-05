class BlogSetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  def ask_about_default_author
    client_user = yes?('Is this blog for a single base client?')
    if client_user == true
      @default_author_name = ask('What is the name of the default author for posts?')
    else
      @default_author_name = nil
    end
  end
  
  def setup
    prepend_to_file 'config/settings.yml', "default_post_author: #{@default_author_name}\n"
  end
  
  # TODO - setup migration
  
end
