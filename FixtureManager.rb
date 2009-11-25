require 'Fixture'

module DmxLib
  class FixtureManager
    attr_reader :fixtures
    
    def initialize
      @fixtures = Hash.new()
    end
    
    def addFixture(name, fixture)
      if(@fixtures.has_key?(name))
        return
      end
      @fixtures[name] = fixture
    end
    
    def remFixtureByName(name)
      raise "remFixtureByName not implemented"
    end
    
    def getFixtureByName(name)
      if(!@fixtures.has_key?(name))
        return nil
      end
      return @fixtures[name]
    end
    
    def setFixtureChannelValue(fixtureName, channelName, value)
      fixture = getFixtureByName(fixtureName)  
      if(fixture == nil)
        return nil;
      end
      return fixture.setChannelValue(channelName, value)
    end
    
    def getFixtureChannelValue(fixtureName, channelName)
      fixture = getFixtureByName(fixtureName)  
      if(fixture == nil)
        return nil;
      end
      return fixture.getChannelValue(channelName)
    end
    
    def getAllFixtureNames
      return @fixtures.keys
    end
   
    def getAllFixturesByUniverseName(name)
      @fixtures.each_value do |fixture|
        if(fixture.universeName == name)
          yield fixture
        end
      end
    end
    
    def getFixtureChannelUpdateFunc(fixtureName, channelName)
      fixture = getFixtureByName(fixtureName)
      return fixture.getChannelUpdateFunc(channelName)
    end
    
    def numFixtures
      @fixtures.length
    end            
  end
end
