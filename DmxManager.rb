require 'FixtureManager'
require 'FixtureDefinition'
require 'UniverseManager'
require 'Input/InputManager'
require 'rexml/document'
require 'thread'
require 'DmxUsbPro'

include REXML

module DmxLib
  class DmxManager
    attr_reader :fixtures
    attr_reader :fixtureDefinitions
    attr_reader :dmxInterface
    attr_reader :dmxUpdateThread
    attr_reader :dmxMutex
    attr_reader :universes
#    attr_reader :effects
#    attr_reader :effectDefinitions
#    attr_reader :inputs
    
    def initialize
      @fixtures = FixtureManager.new()
      @dmxChannelData = Array.new(512)
      (0..512).each do |x|
        @dmxChannelData[x] = 0
      end
      @dmxMutex = Mutex.new
      
      @universes = UniverseManager.new
      
      @effectDefinitions = Hash.new
      @effects = Hash.new
    
      @inputs = InputManager.new
      # discover effects
      if(File.directory? "Effects")
        Dir.foreach("Effects") do |filename|
          if(filename.match(/.*\.rb/))
            puts "foo"
            require "Effects/" + filename
            puts "loading #{filename}"
            match = filename.match(/(.*)\.rb/)
            begin
              ed = eval match[1] + ".register"
              puts "Found effect: " + ed.name
              @effectDefinitions[ed.name] = ed
            rescue
              #debugger
              puts "eval failed"
            end
          end
        end
      end
    end
    
    def addFixture(name, fixture)
      @fixtures.addFixture(name, fixture)
    end
    
    def remFixtureByName(name)
      raise "remFixtureByName not implemented"
    end
    
    def getFixtureByName(name)
      @fixtures.getFixtureByName(name)
    end
    
    def getAllFixtureNames
      @fixtures.getAllFixtureNames
    end
    
    def getFixtureChannel(fixtureName, channelName)
      fixture = getFixtureByName(fixtureName)
      return fixture.getChannelByName(channelName)
    end
    
    def numFixtures
      @fixtures.numFixtures
    end
    
    def setFixtureChannelValue(fixtureName, channelName, value)
        return fixtures.setFixtureChannelValue(fixtureName, channelName, value)
    end
    
    def getFixtureChannelValue(fixtureName, channelName)
        return fixtures.getFixtureChannelValue(fixtureName, channelName)
    end

    def getFixtureChannelUpdateFunc(fixtureName, channelName)
      return fixtures.getFixtureChannelUpdateFunc()
    end
   
    def loadFixtureDefinitions(file)
      @fixtureDefinitions = FixtureDefinitions.new(file)  
    end
    
    # loads fixtures from a file
    def loadFixtures(file)
      if(@fixtureDefinitions == nil)
        raise("Fixture Definitions not loaded")
      end
      
      if(!File.exists?(file))
        raise "file does not exist"
      end
      
      # load xml
      xml = File.new(file)
      doc = Document.new(xml)
      
      # loop through our fixtures
      doc.elements.each("DmxLib/Fixtures/Fixture") do |curFixture|
        f = Fixture.getFixtureFromXml(curFixture, @fixtureDefinitions)
        
        addFixture(f.name, f)
      end
    end
    
    def connectUniverse(universeName)
      begin
        @universes.connectUniverse(universeName)
      rescue Exception => e
        puts e
        raise "could not connect universe #{universeName}"
        
      end
    end
    
    def connectAllUniverses()
      universeNames = getAllUniverseNames()
      universeNames.each do |name|
        connectUniverse(universeName)
      end
    end
        
    def disconnect()
      if(!@dmxInterface.IsConnected())
        return
      end
      
      @dmxMutex.synchronize do
        @dmxUpdateThread.stop
        @dmxInterface.disconnect()
      end
    end
    
    def addUniverse(universeName, universeId, interface)
      puts interface.class
      @universes.addUniverse(universeName, universeId, interface, @fixtures)      
    end
    
    def remUniverse(universename)
      @universes.remUniverse(universeName)
    end
    
    def setUniverseChannelData(universeName, channelNum, value)
      @universes.setUniverseChannelData(universeName, channelNum, value)
    end
    
    def getUniverseChannelData(universeName, channelNum)
      return @universes.getUniverseChannelData(universeName, channelNum)
    end
    
    def getAllUniverseNames()
      return @universes.getAllUniverseNames
    end
    
    def disconnectUniverse(universeName)
      @universes.disconnectUniverse(universeName)
    end
    
    def isUniverseConnected(universeName)
      return @universes.isUniverseConnected(universeName)
    end

#    def getEffectNames()
#      return @effectDefinitions.keys
#    end
#    
#    def getEffectDefinitionByName(effectName)
#      raise "No EffectDefinition by name: #{effectName}" if(!@effectDefinitions.has_key? effectName)
#      return @effectDefinitions[effectName] 
#    end
#    
#    def addEffect(effectName, fixtureNames, params)
#      effectDef = getEffectDefinitionByName(effectName)
#      effect = DmxLib.const_get(effectDef.className).new(self, fixtureNames, params)
#      effect.effectId = effect.object_id
#      @effects[effect.object_id] = effect
#      return effect.object_id
#    end
#    
#    def getAllRunningEffects()
#      return @effects
#    end
#    
#    def getEffectById(effectId)
#      raise "No effect by id #{effectId}" if (!@effects.has_key? effectId)
#      return @effects[effectId]
#    end
#    
#    def startEffect(effectId)
#      e = getEffectById(effectId)
#      e.start
#    end
#    
#    def stopEffect(effectId)
#      e = getEffectById(effectId)
#      e.stop
#    end
#    
#    def remEffect(effectId)
#      getEffectById(effectId)
#      stopEffect(effectId)
#      @effects.delete(effectId)
#    end
#    
#    def getInputTypes()
#      return @inputManager.getInputTypes
#    end
# 
#    def addInput(inputName, inputType)
#      @inputManager.addInput(inputName, inputType)
#    end
#    
#    def getInputDeviceNames(inputName)
#      return @inputManager.getInputDeviceNames(inputName)
#    end
#    
#    def setInputActiveDevice(inputName, deviceName)
#      @inputManager.setInputActiveDevice(inputName, deviceName)
#    end
#    
#    def getInputActiveChannel(inputName)
#      return @inputManager.getInputActiveChannel(inputName)
#    end
#    
#    def remInput(inputName)
#      @inputManager.remInput(inputName)
#    end
  end
end
