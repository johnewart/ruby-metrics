require "rubygems"
require "bundler"
require "rspec/core/rake_task"
Bundler::GemHelper.install_tasks

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

namespace :spec do
  RSpec::Core::RakeTask.new do |t|
    t.name = :activesupport
    t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb -r active_support -r active_support/json"]
    t.pattern = 'spec/**/*_spec.rb'
  end
end

task :default => :spec
