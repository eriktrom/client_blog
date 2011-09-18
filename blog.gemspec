# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "blog"
  s.authors = "Erik Trom"
  s.summary = "Insert Blog summary."
  s.description = "Insert Blog description."
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
  s.version = "0.0.1"
  
  s.add_dependency 'acts-as-taggable-on'
  s.add_dependency 'ancestry'
  
end