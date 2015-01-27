class Fluent::StringScrubOutput < Fluent::Output
  Fluent::Plugin.register_output('string_scrub', self)

  config_param :tag, :string, :default => nil
  config_param :remove_prefix, :string, :default => nil
  config_param :add_prefix, :string, :default => nil
  config_param :replace_char, :string, :default => ''

  def initialize
    super
    require 'string/scrub' if RUBY_VERSION.to_f < 2.1
  end

  def configure(conf)
    super

    if not @tag and not @remove_prefix and not @add_prefix
      raise Fluent::ConfigError, "missing both of remove_prefix and add_prefix"
    end
    if @tag and (@remove_prefix or @add_prefix)
      raise Fluent::ConfigError, "both of tag and remove_prefix/add_prefix must not be specified"
    end
    if @remove_prefix
      @removed_prefix_string = @remove_prefix + '.'
      @removed_length = @removed_prefix_string.length
    end
    if @add_prefix
      @added_prefix_string = @add_prefix + '.'
    end

    if @replace_char and @replace_char.length >= 2
        raise Fluent::ConfigError, "replace_char: mast be 1 character"
    end
  end

  def emit(tag, es, chain)
    tag = if @tag
            @tag
          else
            if @remove_prefix and
                ( (tag.start_with?(@removed_prefix_string) and tag.length > @removed_length) or tag == @remove_prefix)
              tag = tag[@removed_length..-1]
            end
            if @add_prefix
              tag = if tag and tag.length > 0
                      @added_prefix_string + tag
                    else
                      @add_prefix
                    end
            end
            tag
          end

    es.each do |time,record|
      scrubbed = recv_record(record)
      next if scrubbed.nil?
      Fluent::Engine.emit(tag, time, scrubbed)
    end

    chain.next
  end

  def recv_record(record)
    scrubbed = {}
    record.each do |k,v|
      if v.instance_of? Hash
        scrubbed[with_scrub(k)] = recv_record(v)
      else
        scrubbed[with_scrub(k)] = with_scrub(v)
      end
    end
    scrubbed
  end

  def with_scrub(string)
    begin
      string =~ //
      return string
    rescue ArgumentError => e
      raise e unless e.message.index("invalid byte sequence in") == 0
      string.scrub!(@replace_char)
      retry
    end
  end
end
