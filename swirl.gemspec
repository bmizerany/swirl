Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'swirl'
  s.version = '1.5.2'
  s.date = '2010-01-26'

  s.description = "A version agnostic EC2 ruby driver"
  s.summary     = s.description

  s.authors = ["Blake Mizerany"]

  # = MANIFEST =
  s.files = %w[LICENSE README.md list-types] +
    Dir["{lib,test}/**/*.rb"] +
    ["bin/swirl"]

  s.executables = ["swirl"]

  # = MANIFEST =

  s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}

  s.extra_rdoc_files = %w[README.md LICENSE]
  s.add_dependency 'crack',    '>= 0.1.4'
  s.add_dependency 'ruby-hmac',    '>= 0.3.2'
  s.add_development_dependency 'contest', '>= 0.1.2'

  s.has_rdoc = true
  s.homepage = "http://github.com/bmizerany/swirl"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Sinatra", "--main", "README.rdoc"]
  s.require_paths = %w[lib]
  s.rubyforge_project = 'swirl'
  s.rubygems_version = '1.1.1'
end
