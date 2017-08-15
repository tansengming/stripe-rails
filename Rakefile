#!/usr/bin/env rake
require "bundler/gem_tasks"

desc "run minitests"
task :spec do
  sh "bundle exec ruby -Itest test/all.rb"
end

task :default => :spec