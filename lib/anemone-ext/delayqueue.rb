require 'thread'
require 'uri'

module Anemone
  class DelayQueue < Queue
    attr_accessor :delay_time

    def initialize
      super()
      @lastcrawl = Hash.new {|h,k| Time.at(0) }
      @delay_time = 3
      @pop_lock = Mutex.new
    end

    def enq(e)
      unless e.kind_of?(String) || e.kind_of?(URI::HTTP)
        raise ArgumentError,"element is not String object, type is #{e.class}}"
      end
      super(e)
    end

    def deq
      @pop_lock.synchronize do
        loop do
          uri = super
          uri = URI(uri) if uri.kind_of?(String)
          host = uri.host
          if Time.now - @lastcrawl[host] > @delay_time
            @lastcrawl[host] = Time.now
            return uri
          else
            enq(uri)
          end
        end
      end
    end

    alias :pop  :deq
    alias :push :enq
  end
end
