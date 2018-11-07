#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_spec.rb'
  t.verbose = true
end

task default: :spec