require 'helper'

class StringScrubFilterTest < Test::Unit::TestCase
  include Fluent

  def setup
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  CONFIG = %[
    replace_char ?
  ]

  CONFIG_UNICODE_1 = %[
    replace_char \uFFFD
  ]

  CONFIG_UNICODE_2 = %[
    replace_char \u{FFFD}
  ]

  def create_driver(conf=CONFIG, tag='test.filter')
    Fluent::Test::FilterTestDriver.new(Fluent::StringScrubFilter).configure(conf, tag)
  end

  def filter(config, msgs)
    d = create_driver(config)
    d.run {
      msgs.each {|msg|
        d.filter(msg, @time)
      }
    }
    filtered = d.filtered_as_array
    filtered.map {|m| m[2] }
  end

  def test_filter1
    return unless defined? Fluent::Filter

    orig_message = 'testtesttest'
    invalid_utf8 = "\xff".force_encoding('UTF-8')
    msg = {"message" => orig_message + invalid_utf8}
    filtered = filter(CONFIG, [msg])
    assert_equal([{"message" => orig_message + '?'}], filtered)
  end

end
