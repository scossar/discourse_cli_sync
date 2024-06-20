# frozen_string_literal: true

require 'minitest/reporters'

desc 'Run tests'
task :test do
  require 'minitest/autorun'
  Dir.glob('test/**/*_test.rb') { |file| require File.expand_path(file) }
end

task default: :test
