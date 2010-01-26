Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'sinatra'
  s.version = '0.10.1'
  s.date = '2009-12-13'

  s.description = "Classy web-development dressed in a DSL"
  s.summary     = "Classy web-development dressed in a DSL"

  s.authors = ["Blake Mizerany", "Ryan Tomayko", "Simon Rozet"]
  s.email = "sinatrarb@googlegroups.com"

  # = MANIFEST =
  s.files = %w[LICENSE README.md list-types] + Dir["{bin,lib,test}/**/*.rb"]
  # = MANIFEST =

  s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}

  s.extra_rdoc_files = %w[README.md LICENSE]
  s.add_dependency 'crack',    '>= 1.4'
  s.add_dependency 'ruby-hmac',    '>= 0.3.2'
  s.add_development_dependency 'contest', '>= 0.1.2'

  s.has_rdoc = true
  s.homepage = "http://github.com/bmizerany/swirl"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Sinatra", "--main", "README.rdoc"]
  s.require_paths = %w[lib]
  s.rubyforge_project = 'swirl'
  s.rubygems_version = '1.1.1'
end
