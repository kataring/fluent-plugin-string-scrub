require 'fluent/plugin/filter'

class Fluent::Plugin::StringScrubFilter < Fluent::Plugin::Filter
  Fluent::Plugin.register_filter('string_scrub', self)

  config_param :replace_char, :string, :default => ''

  def initialize
    super
  end

  def configure(conf)
    super

    if @replace_char =~ /\\u\{*[A-F0-9]{4}\}*/
      @replace_char = eval("\"#{@replace_char}\"")
    end
  end

  def filter(_tag, _time, record)
    recv_record(record)
  end

  def recv_record(record)
    scrubbed = {}
    record.each do |k, v|
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
