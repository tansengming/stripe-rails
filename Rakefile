#!/usr/bin/env rake
require "bundler/gem_tasks"

desc "run minitests"
task :spec do
  sh "bundle exec ruby -Itest test/all.rb"

  cd 'test/dummy' do
    sh "bundle exec rails test:system"
  end
end

task :default => :spec