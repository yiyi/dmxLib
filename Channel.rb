
module DmxLib
  #require 'ruby-debug'
  require 'thread'
  class Channel
    attr_reader :channelOffset
    attr_reader :name
    attr_reader :type
    attr_reader :curValue
    
    def initialize(name, type, channelOffset)
      @name = name
      @type = type
      @channelOffset = channelOffset
      @curValue = 0
      @channelMutex = Mutex.new
    end
  
    def setChannelValue(value)

      # validate the params
      if(value > 254) 
        value = 254
      end
      if(value < 0)
        value = 0
      end

      @channelMutex.synchronize do
       #puts $debug
        #debugger if $debug == 1
       @curValue = value 
      end
    end
    
    def getChannelValue()
      @channelMutex.synchronize do
        return @curValue        
      end
    end
    
    def getUpdateFunc()
      return self.method(setChannelValue)
    end
  end
end
