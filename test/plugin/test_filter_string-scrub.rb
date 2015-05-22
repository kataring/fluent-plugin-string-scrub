require 'helper'

class StringScrubFilterTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG_UNICODE_1 = %[
    replace_char \uFFFD
  ]

  CONFIG_UNICODE_2 = %[
    replace_char \u{FFFD}
  ]

  def create_driver(conf=CONFIG, tag='test.filter')
    Fluent::Test::FilterTestDriver.new(Fluent::StringScrubFilter).configure(conf, tag)
  end

  def test_emit1_invalid_string
    return unless defined? Fluent::Filter

    d = create_driver(%[
      replace_char ?
    ])
    orig_message = 'testtesttest'
    invalid_utf8 = "\xff".force_encoding('UTF-8')
    replace_char = '?'
    time = Time.parse("2015-05-22 11:22:33 UTC").to_i

    es = Fluent::MultiEventStream.new
    es.add(time, {"message" => orig_message + invalid_utf8})

    filtered_es = d.filter_stream('test.filter', es)
    assert_equal 1, records.length
    assert_equal({"message" => orig_message + replace_char}, records[0])
  end

end
