$:.unshift(File.dirname(__FILE__) + '/lib')
require "rubygems"
require "bundler"
require "rspec/core/rake_task"
require 'ruby-metrics/version'

desc 'Build gem into the pkg directory'
task :build do
  FileUtils.rm_rf('pkg')
  Dir['*.gemspec'].each do |gemspec|
    puts "Building #{gemspec}"
    system "gem build #{gemspec}"
  end
  FileUtils.mkdir_p('pkg')
  FileUtils.mv(Dir['*.gem'], 'pkg')
end

desc 'Tags version, pushes to remote, and pushes gem'
task :release => :build do
  puts "Releasing v#{Metrics::VERSION}"
  sh 'git', 'tag', '-m', "Version #{Metrics::VERSION}",  "v#{Metrics::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{Metrics::VERSION}"
  sh "ls pkg/*.gem | xargs -n 1 gem push"
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec
