# frozen_string_literal: true

begin
  addpath = lambda do |p|
    path = File.expand_path("../../#{p}", __FILE__)
    $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
  end
  addpath.call('lib')
end

require 'cli/kit'
require 'discourse' # needs to be included to be able to access `Discourse:Config` in tests

require 'fileutils'
require 'tmpdir'
require 'tempfile'

require 'rubygems'
require 'bundler/setup'

CLI::UI::StdoutRouter.enable

require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/minitest'
