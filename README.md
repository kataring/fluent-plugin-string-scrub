# fluent-plugin-string-scrub [![Gem Version](https://badge.fury.io/rb/fluent-plugin-string-scrub.svg)](http://badge.fury.io/rb/fluent-plugin-string-scrub)

fluent plugin for string scrub.

## [String#scrub](https://github.com/hsbt/string-scrub)

>If the given string contains an invalid byte sequence then that invalid byte sequence is replaced with the [unicode replacement character](http://www.fileformat.info/info/unicode/char/0fffd/index.htm) (�) and a new string is returned.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-string-scrub'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-string-scrub

## Configuration

```
<match **>
  @type string_scrub
  tag scrubbed.string
  replace_char ?
</match>
```

## Usage

```
<source>
  @type forward
</source>

<match raw.**>
  @type string_scrub
  remove_prefix raw
  add_prefix scrubbed
</match>

<match scrubbed.**>
  @type stdout
</match>
```

## Filter plugin

Fluentd >= v0.12 can use filter plugin.

```
<source>
  @type forward
</source>

<filter **>
  @type string_scrub
  replace_char ?
</filter>

<match **>
  @type stdout
</match>
```


## Contributing

1. Fork it ( https://github.com/kataring/fluent-plugin-string-scrub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
