require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'fluent/test'
require 'fluent/version'
require 'fluent/test/driver/output'
require 'fluent/test/driver/filter'
require 'fluent/plugin/out_string_scrub'
require 'fluent/plugin/filter_string_scrub'

class Test::Unit::TestCase
end
