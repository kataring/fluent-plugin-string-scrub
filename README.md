# fluent-plugin-string-scrub [![Build Status](https://travis-ci.org/kataring/fluent-plugin-string-scrub.svg)](https://travis-ci.org/kataring/fluent-plugin-string-scrub) 

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
  type string_scrub
  tag scrubbed.string
</match>
```

## Usage

```
<source>
  type forward
</source>

<match raw.**>
  type string_scrub
  remove_prefix raw
  add_prefix scrubbed
</match>

<match scrubbed.**>
  type stdout
</match>
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fluent-plugin-string-scrub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
