require File.dirname(__FILE__) + '/spec_helper'
require 'anemone-ext/delayqueue'

module Anemone
  describe DelayQueue do
    DELAY_TIME = 2
    
    before(:each) do
      @queue = DelayQueue.new
      @queue.delay_time = DELAY_TIME
    end
    
    it "is pushed integer object throws exception" do
      lambda { @queue.enq(1) }.should raise_error(ArgumentError)
      lambda { @queue.push(1) }.should raise_error(ArgumentError)
    end

    it "is pushed String object, not throws exception" do
      @queue.enq("abc")
      @queue.push("xyz")
    end

    it "is pushed String object, not throws exception" do
      @queue.enq(URI("http://www.example.com"))
      @queue.push(URI("http://www2.example.com"))
    end
    
    it "pop delayed same host uri string" do
      @queue.push("http://www.yahoo.co.jp/test")
      @queue.push("http://www.yahoo.co.jp/test2")

      time do
        threads = []
        @queue.size.times {
          threads << Thread.new { @queue.pop} 
        }
        threads.each {|thread| thread.join }
      end.should > DELAY_TIME
    end

    it "pop delayed same host URI::HTTP" do
      @queue.push(URI.parse("http://www.yahoo.co.jp/"))
      @queue.push(URI.parse("http://www.yahoo.co.jp/"))

      time do
        threads = []
        @queue.size.times {
          threads << Thread.new { @queue.pop} 
        }
        threads.each {|thread| thread.join }
      end.should > DELAY_TIME
    end

    it "pop not delayed deferent host uri" do
      @queue.push("http://www.yahoo.co.jp/test")
      @queue.push("http://www.yahoo.com/test2")
      
      time do
        threads = []
        @queue.size.times {
          threads << Thread.new { @queue.pop} 
        }
        threads.each {|thread| thread.join } 
      end.should < 1
    end

    private

    def time
      start = Time.now
      yield
      Time.now - start
    end
  end
end
