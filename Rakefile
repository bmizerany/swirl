require File.join(File.dirname(__FILE__), 'vendor', 'gems', 'environment')

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end
