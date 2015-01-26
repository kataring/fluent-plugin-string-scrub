require 'helper'

class StringScrubOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    remove_prefix input
    add_prefix    scrubbed
  ]

  def create_driver(conf=CONFIG,tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::StringScrubOutput, tag).configure(conf)
  end

  def test_configure
    assert_raise(Fluent::ConfigError) {
      d = create_driver('')
    }
    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        tag foo.bar
        remove_prefix removed
      ]
    }
    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        tag foo.bar
        add_prefix    added
      ]
    }
    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        tag foo.bar
        remove_prefix removed
        add_prefix    added
      ]
    }
    assert_nothing_raised {
      d = create_driver %[
        tag foo.bar
      ]
    }
    assert_nothing_raised {
      d = create_driver %[
        add_prefix    added
      ]
    }
    assert_nothing_raised {
      d = create_driver %[
        remove_prefix removed
      ]
    }
    assert_nothing_raised {
      d = create_driver %[
        remove_prefix removed
        add_prefix    added
      ]
    }
  end

  def test_emit1_invalid_byte
    orig_message = 'testtesttest'
    invalid_utf8 = "\xff".force_encoding('UTF-8')
    d1 = create_driver(CONFIG, 'input.log')
    d1.run do
      d1.emit({'message' => orig_message + invalid_utf8})
    end
    emits = d1.emits
    assert_equal 1, emits.length
    
    e1 = emits[0]
    assert_equal "scrubbed.log", e1[0]
    assert_equal orig_message, e1[2]['message']

    invalid_ascii = "\xff".force_encoding('US-ASCII')
    d2 = create_driver(CONFIG, 'input.log2')
    d2.run do
      d2.emit({'message' => orig_message + invalid_utf8})
    end
    emits = d2.emits
    assert_equal 1, emits.length
    
    e2 = emits[0]
    assert_equal "scrubbed.log2", e2[0]
    assert_equal orig_message, e2[2]['message']
  end
end
