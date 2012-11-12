#!/usr/bin/env rake
require "bundler/gem_tasks"

desc "run minitests"
task :spec do
  sh "bundle exec ruby -Itest test/*_spec.rb"
end

task :default => :spec