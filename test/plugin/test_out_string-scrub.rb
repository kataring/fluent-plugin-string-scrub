require 'helper'

class StringScrubOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    remove_prefix input
    add_prefix scrubbed
  ]

  CONFIG_REPLACE_CHAR = %[
    remove_prefix input
    add_prefix scrubbed
    replace_char ?
  ]

  CONFIG_UNICODE_1 = %[
    remove_prefix input
    add_prefix scrubbed
    replace_char \uFFFD
  ]

  CONFIG_UNICODE_2 = %[
    remove_prefix input
    add_prefix scrubbed
    replace_char \u{FFFD}
  ]

  def create_driver(conf = CONFIG, tag = 'test', use_v1_config = true)
    Fluent::Test::OutputTestDriver.new(Fluent::StringScrubOutput, tag).configure(conf, use_v1_config)
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
        add_prefix added
      ]
    }
    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        tag foo.bar
        remove_prefix removed
        add_prefix added
      ]
    }
    assert_nothing_raised {
      d = create_driver %[
        tag foo.bar
      ]
    }
    assert_nothing_raised {
      d = create_driver %[
        add_prefix added
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
        add_prefix added
      ]
    }
  end

  def test_emit_fluentd_0_12
    if Fluent::VERSION >= "0.12"
      in_tag = 'input.log'
      orig_message = 'testtesttest'
      Fluent::Engine.root_agent.add_label('@foo')
      d = create_driver(%[
                        @label @foo
                        ], in_tag)
      label = Fluent::Engine.root_agent.find_label('@foo')
      assert_equal(label.event_router, d.instance.router)

      d.run do
        d.emit({'message' => orig_message})
      end
      emits = d.emits
      tag, time, record = emits.first
      assert_equal(in_tag, tag)
    end
  end

  def test_emit1_invalid_string
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

  def test_emit2_replace_char
    orig_message = 'testtesttest'
    invalid_utf8 = "\xff".force_encoding('UTF-8')
    d1 = create_driver(CONFIG_REPLACE_CHAR, 'input.log')
    d1.run do
      d1.emit({'message' => orig_message + invalid_utf8})
    end
    emits = d1.emits
    assert_equal 1, emits.length

    e1 = emits[0]
    assert_equal "scrubbed.log", e1[0]
    assert_equal orig_message + '?', e1[2]['message']

    invalid_ascii = "\xff".force_encoding('US-ASCII')
    d2 = create_driver(CONFIG_REPLACE_CHAR, 'input.log2')
    d2.run do
        d2.emit({'message' => orig_message + invalid_utf8})
    end
    emits = d2.emits
    assert_equal 1, emits.length

    e2 = emits[0]
    assert_equal "scrubbed.log2", e2[0]
    assert_equal orig_message + '?', e2[2]['message']
  end

  def test_emit3_struct_message
    orig_message = 'testtesttest'
    invalid_utf8 = "\xff".force_encoding('UTF-8')
    d1 = create_driver(CONFIG_REPLACE_CHAR, 'input.log')
    d1.run do
      d1.emit({'message' => {'message_child' => orig_message + invalid_utf8}})
    end
    emits = d1.emits
    assert_equal 1, emits.length

    e1 = emits[0]
    assert_equal "scrubbed.log", e1[0]
    assert_equal orig_message + '?', e1[2]['message']['message_child']
  end

  def test_emit4_unicode1
    orig_message = 'testtesttest'
    invalid_utf8 = "\xff".force_encoding('UTF-8')
    d1 = create_driver(CONFIG_UNICODE_1, 'input.log')
    d1.run do
      d1.emit({'message' => {'message_child' => orig_message + invalid_utf8}})
    end
    emits = d1.emits
    assert_equal 1, emits.length

    e1 = emits[0]
    assert_equal "scrubbed.log", e1[0]
    assert_equal orig_message + "\uFFFD".force_encoding('UTF-8'), e1[2]['message']['message_child']

    orig_message = 'testtesttest'
    invalid_utf8 = "\xff".force_encoding('UTF-8')
    d1 = create_driver(CONFIG_UNICODE_2, 'input.log')
    d1.run do
      d1.emit({'message' => {'message_child' => orig_message + invalid_utf8}})
    end
    emits = d1.emits
    assert_equal 1, emits.length

    e1 = emits[0]
    assert_equal "scrubbed.log", e1[0]
    assert_equal orig_message + "\uFFFD".force_encoding('UTF-8'), e1[2]['message']['message_child']
  end

  def test_emit5_frozen_string
    orig_message = 'testtesttest'
    invalid_utf8 = "\xff".force_encoding('UTF-8')
    d1 = create_driver(CONFIG, 'input.log')
    d1.run do
      d1.emit({'message' => (orig_message + invalid_utf8).freeze})
    end
    emits = d1.emits
    assert_equal 1, emits.length
    
    e1 = emits[0]
    assert_equal "scrubbed.log", e1[0]
    assert_equal orig_message, e1[2]['message']

    invalid_ascii = "\xff".force_encoding('US-ASCII')
    d2 = create_driver(CONFIG, 'input.log2')
    d2.run do
      d2.emit({'message' => (orig_message + invalid_utf8).freeze})
    end
    emits = d2.emits
    assert_equal 1, emits.length
    
    e2 = emits[0]
    assert_equal "scrubbed.log2", e2[0]
    assert_equal orig_message, e2[2]['message']
  end
end
