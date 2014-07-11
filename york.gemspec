Gem::Specification.new do |s|
  s.name              = 'york'
  s.version           = '0.1.0'
  s.summary           = 'Jekyll plugin for writing about programming'
  s.author            = 'James Coglan'
  s.email             = 'jcoglan@gmail.com'
  s.homepage          = 'http://github.com/jcoglan/york'
  s.license           = 'MIT'

  s.extra_rdoc_files  = %w[README.md]
  s.rdoc_options      = %w[--main README.md --markup markdown]
  s.require_paths     = %w[lib]

  s.files = %w[README.md] + Dir.glob('lib/**/*.rb')

  s.add_dependency 'jekyll'
  s.add_dependency 'nokogiri'
  s.add_dependency 'pygments.rb'

  s.add_development_dependency 'github-linguist'
end
