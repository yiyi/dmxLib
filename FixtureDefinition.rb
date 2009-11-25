module DmxLib
  require 'Channel.rb'
  require 'ChannelManager.rb'
  class FixtureDefinitions
    attr_reader :fixtures
    
    def initialize(file)
      @fixtures = Hash.new
      
     if(!File.exists?(file))
        raise "file does not exist: #{file}"
      end
      
      # load xml
      xml = File.new(file)
      doc = Document.new(xml)
      
      # loop through our fixtures
      doc.elements.each("DmxLib/FixtureDefinitions/FixtureDefinition") do |curFixture|
        # create our fixture
        f = FixtureDefinition.new(curFixture)
        @fixtures[f.name] = f        
      end
    end
    
    def getFixtureDefinition(name)
      if(@fixtures.has_key? name)
        return @fixtures[name]
      else
        return nil
      end
    end
  end
  
  class FixtureDefinition
    attr_reader :channels
    attr_reader :name
    attr_reader :numChannels
    attr_reader :type
    attr_reader :manufacturer
    
    def initialize(fixtureXml)
      @channels = Hash.new 
      @name = fixtureXml.attributes["Name"]
      @numChannels = fixtureXml.attributes["NumChannels"]
      @type = fixtureXml.attributes["Type"]
      @manufacturer = fixtureXml.attributes["Manufacturer"]
      fixtureXml.elements.each("ChannelDefinition") do |channel|
        c = ChannelDefinition.new(channel)
        @channels[c.name] = c
      end
    end
    
    def getChannels
      if(@channels == nil || @channels.length == 0)
        return nil
      end
      
      
      c = Array.new

      @channels.each_value do |channel|
        c.push(Channel.new(channel.name, channel.type, channel.channelOffset))
      end
      
      return c
    end
  end
  
  class ChannelDefinition
    attr_reader :name
    attr_reader :type
    attr_reader :channelOffset
    
    def initialize(channelXml)
      @name = channelXml.attributes["Name"]
      @type = channelXml.attributes["Type"]
      @channelOffset = channelXml.attributes["ChannelOffset"]
    end
  end
end