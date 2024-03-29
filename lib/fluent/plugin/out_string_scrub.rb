require 'fluent/plugin/output'

class Fluent::Plugin::StringScrubOutput < Fluent::Plugin::Output
  Fluent::Plugin.register_output('string_scrub', self)

  helpers :event_emitter

  config_param :tag, :string, :default => nil
  config_param :remove_prefix, :string, :default => nil
  config_param :add_prefix, :string, :default => nil
  config_param :replace_char, :string, :default => ''

  def initialize
    super
  end

  def configure(conf)
    super

    if conf['@label'].nil?
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
    end

    if @replace_char =~ /\\u\{*[A-F0-9]{4}\}*/
      @replace_char = eval("\"#{@replace_char}\"")
    end
  end

  def process(tag, es)
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
      router.emit(tag, time, scrubbed)
    end
  end

  def recv_record(record)
    scrubbed = {}
    record.each do |k,v|
      if v.instance_of? Hash
        scrubbed[with_scrub(k)] = recv_record(v)
      elsif v.instance_of? Integer
        scrubbed[k] = v
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
      if string.frozen?
          string = string.dup.scrub!(@replace_char)
      else
          string.scrub!(@replace_char)
      end
      retry
    end
  end
end
