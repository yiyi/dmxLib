module DmxLib
  require 'thread'
  
  class Universe
    attr_reader :name
    attr_reader :id
    attr_reader :interface
    attr_reader :updateThread
    attr_reader :fixtures
    attr_reader :universeMutex
    
    def initialize(name, id, interface, fixtures)
      @name = name
      @id = id
      @interface = interface
      @fixtures = fixtures
      @universeMutex = Mutex.new
    end    
    
    def isConnected()
      return @interface.isConnected
    end
    
    def disconnect()
      @universeMutex.synchronize do
        @updateThread.stop
        @interface.disconnect
      end
    end
    
    def updateDmxValues()
      # loop through our fixtures and get their channel values
       @fixtures.getAllFixturesByUniverseName(name) do |fixture|
        baseChannel = fixture.baseChannel
     
        fixture.getAllChannels().each do |channel|
          channelNum = baseChannel.to_i + channel.channelOffset.to_i
          @interface.setChannel(channelNum, channel.curValue)
        end
      end
    end
    
    def connect()
      puts "in connect"
            
      if(@interface.connect == false || !isConnected)
        raise "Could not connect"  
      end      
      if(isConnected)
        updateDmxValues
        # start update thread
        @updateThread = Thread.new(@interface) do |device|
          loop do
            @universeMutex.synchronize do
              updateDmxValues
              device.sendData()
            end
            sleep(0.1)
          end
        end
      end
    end
    
    def setChannelData(channelNum, value)
      @universeMutex.synchronize do
        interface.setChannel(channelNum, value)
      end
    end
    
    def getChannelData(channelNum)
      @universeMutex.synchronize do
        return interface.getChannel(channelNum)
      end
    end  
  end
  
  class UniverseManager
    attr_reader :universes
      
    def initialize()
      @universes = Hash.new
    end
    
    def addUniverse(name, id, interface, fixtures)
      universes[name] = Universe.new(name, id, interface, fixtures)    
    end
    
    def remUniverse(name)
      universe = getUniverseByName(name)
      universe.disconnect
      universes.delete(name)
    end
    
    def connectUniverse(name)
      universe = getUniverseByName(name)    
      
      if(universe.isConnected)
        universe.disconnect
      end
      
      universe.connect
    end
    
    def getUniverseByName(name)
      if(!@universes.has_key? name)
        raise("could not find universe #{name}")
      end
      
      return @universes[name]
    end
    
    def getAllUniverseNames()
      return @universes.keys    
    end
    
    def isUniverseConnected(name)
      universe = getUniverseByName(name)
      return universe.isConnected
    end
    
    def disconnectUniverse(name)
      universe = getUniverseByName(name)
      if(universe.isConnected)
        universe.disconnect
      end
    end
    
    def getUniverseChannelData(universe, channelNum)
      universe = getUniverseByName(universe)
      return universe.getChannelData(channelNum)
    end
    
    def setChannelData(universe, channelNum, value)
      universe = getUniverseByName(universe)
      universe.setChannelData(channelNum, value)
    end
  end
end