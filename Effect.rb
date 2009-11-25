module DmxLib
  require 'thread'
  #require 'ruby-debug'
  class Effect
    attr_reader :updateThread
    attr_reader :effectName
    attr_reader :threadMutex
    attr_reader :fixtureNames
    attr_reader :dmxManager
    attr_reader :className
    attr_reader :isRunning
    attr_accessor :effectId
    
    def initialize(dmxManager, fixtureNames, params)
      @dmxManager = dmxManager
      @fixtureNames = fixtureNames
      @threadMutex = Mutex.new
    end
    
    def self.register
      raise NotImplementedError
    end
    
    def getEffectDefinition
      return NotImplementedError
    end
    
    def start
      puts "starting thread"
      if(@updateThread != nil)
        @updateThread.kill
      end
      @isRunning = true
      @updateThread = Thread.new do 
        loop do
          @threadMutex.synchronize do
            update
            puts "foo"
          end
        end
      end
    end
    
    def stop
      return unless isRunning 
      @updateThread.kill
      @updateThread = nil
      @isRunning = false
    end
    
    def update
      raise NotImplementedError
    end
    
    def getUpdateFunc()
      return self.method(setParams)
    end
    
    def setParams(params)
      raise NotImplementedError
    end  
  end
end