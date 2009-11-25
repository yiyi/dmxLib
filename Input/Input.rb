module DmxLib
  require 'thread'
  
  class InputMap
    attr_reader :inputChannel
    def initialize(inputChannel, updateFunc)
      @inputChannel = inputChannel
      @updateFunc = updateFunc
    end
    
    def updateValue(value)
      @updateFunc.call(value)
    end
  end
  
#  class ChannelInputMap < InputMap
#    def initialize(inputChannel, channel)
#      @channel = channel
#      super(inputChannel)
#    end
#    
#    def updateValue(value)
#      
#    end
#  end
#  
#  class EffectInputMap < InputMap
#    def initialize(inputChannel, updateFunc)
#      @effect = effect
#      @param = param
#      super(inputChannel)
#    end
#  end
  
#  class SystemInputMap < InputMap
#    def initialize(inputChannel, SystemParam)
#    end
#  end

  class Input
    attr_reader :thread
    attr_reader :updateRate
    attr_reader :mutex
    attr_reader :inputType
    attr_reader :inputMap
    attr_reader :channelData
    attr_reader :lastData
    
    def initialize()
      @thread = nil
      @updateRate = 0.01
      @mutex = Mutex.new
      @channelData = Hash.new
      @inputMap = Hash.new
      @lastData = nil
    end
    
    def getData()
      @mutex.synchronize do
        cmd = (@channelData.length == 0) ? nil : @channelData.pop
      end
      return cmd
    end
    
    def isRunning
      return @thread == nil
    end
    
    def start
      stop() if @thread != nil
      init
      @thread = Thread.new() do 
        loop do
          update()
          @mutex.synchronize do
            sleep(@updateRate)
          end
        end
      end
    end
    
    def stop
      @thread.stop  
      @thread = nil
    end
    
    def init()
      raise NotImplementedError
    end
    
    def update()
      raise NotImplementedError
    end
    
    def setActiveDevice(deviceName)
      raise NotImplementedError
    end
    
    def getDeviceNames()
      raise NotImplementedError
    end
    
    def addInputMap(channel, inputMap)
      
    end
    
    def updateParams(params)
      params.each do |key, value|
        case key
          when :updateRate # update the updateRate
            @mutex.synchronize do
              @updateRate = value
            end
        end
      end
    end
    
    def addInputMap(inputMap)
      @inputMap[inputMap.inputChannel] = inputMap
    end
    
    def getActiveChannel()
      raise NotImplementedError 
    end
    
    def clearInputBuffer()
      @channelData.clear()
      @lastData = nil
    end
  end
end