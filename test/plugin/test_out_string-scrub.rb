require 'helper'

class StringScrubOutputTest < Test::Unit::TestCase
  def setup
      Fluent::Test.setup
  end

  CONFIG = %[
  ]

  def create_driver(conf=CONFIG,tag='test')
      Fluent::Test::OutputTestDriver.new(Fluent::StringScrubOutput, tag).configure(conf)
  end

  def test_configure

  end
end
