
require 'rake'
require 'rake/testtask'

namespace :gem do
  desc "Install the gem locally"
  task :install do
    puts "Building gem"
    `gem build artifacts-web.gemspec`
    puts "Installing gem"
    `sudo gem install ./artifacts-web-*.gem`
    puts "Removing built gem"
    `rm artifacts-web-*.gem`
  end
end

namespace :git do
  desc "make a git tag"
  task :tag do
    version = `awk -F \\\" ' /version/ { print $2 } ' artifacts-web.gemspec`
    puts "Tagging git with version=#{version}"
    system "git tag #{version}"
    system "git push --tags"
  end
end


Rake::TestTask.new do |t|
 t.libs << 'test'
end

desc "Run tests"
task :default => :test

