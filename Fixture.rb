
require 'ChannelManager'
module DmxLib
  class Fixture
    attr_reader :universeName
    attr_reader :baseChannel
    attr_reader :channels
    attr_reader :type
    attr_reader :name

    def initialize(name, type, universeName, baseChannel)
      @universeName = universeName
      @name = name
      @type = type
      @baseChannel = baseChannel
      @channels = ChannelManager.new
    end
    
    def self.getFixtureFromXml(fixtureXml, fixtureDefinitions)
      name = fixtureXml.attributes["Name"]
      universe = fixtureXml.attributes["UniverseName"]
      baseChannel = fixtureXml.attributes["BaseChannel"]
      type = fixtureXml.attributes["Type"]      
  
      fixture = Fixture.new(name, type, universe, baseChannel)
      
      fd = fixtureDefinitions.getFixtureDefinition(type)
      if(fd == nil)
        raise("Could not find fixture '#{@name}' of type '#{@type}' in definitions")
      end
      
      fd.getChannels().each do |channel|
        fixture.addChannel(channel.name, channel)
      end
      
      if(fixture.channels == nil)
        raise "Could not load channels for fixture '#{@name}'"
      end  
      
      return fixture
    end
  
    def addChannel(name, channel)
      @channels.addChannel(name, channel)
    end
    
    def remChannelByName(name)
      raise "remChannelByName not implemented"
    end
    
    def getChannelByName(name)
      return @channels.getChannelByName(name)
    end
    
    def getAllChannels
      @channels.getAllChannels
    end
    
    def setChannelValue(channelName, value)
      channel = getChannelByName(channelName)
      if(channel == nil)
        return nil
      end
      return channel.setChannelValue(value)
    end
    
    def getChannelValue(channelName)
      channel = getChannelByName(channelName)
      if(channel == nil)
        return nil
      end
      return channel.getChannelValue()
    end
  
    def getChannelUpdateFunc(channelName)
      return @channels.getChannelUpdateFunc(channelName)
    end
    def numChannels
      @channels.numChannels()
    end
  end
end
