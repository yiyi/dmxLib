if __FILE__ == $0
  
  require 'DmxManager.rb'
  require 'DmxUsbPro'
  require "ruby-debug"
  include DmxLib

 
########### test class for fading colors of a fixture
 class ColorFade
    
    def initialize(fixture, channel, initialValue, speed)
      @initialValue = initialValue
      @channel = channel
      @fixture = fixture
      @speed = speed
      @direction = 1
      $dm.setFixtureChannelValue(fixture, channel, initialValue)
      @threadMutex = Mutex.new
    end
    
    # our update method
    def update(fixture, channel)
     curVal = $dm.getFixtureChannelValue(fixture, channel)
     (@direction == 1) ? curVal += 5 : curVal -= 5
      if(curVal >= 254)
        curVal = 254
        @direction = 0
      elsif (curVal <= 1)
        curVal = 1
        @direction = 1
      end  
      
      begin      
        $dm.setFixtureChannelValue(fixture, channel, curVal)      
      rescue 
        puts "error in thread "
      end
    end
    
    def setSpeed(speed)
      @threadMutex.synchronize do
        @pseed = speed  
      end
    end
    
    def start
      # this is the update thread
      @thread = Thread.new(@fixture, @channel) do | fixture, channel |
        loop do
          update(fixture, channel)
          @threadMutex.synchronize do
            sleep(@speed)
          end
        end
      end
    end
    
    def stop
      @thread.stop
    end
  end 



############### start our stuffs

  $dm = DmxManager.new()
  # load our fixture definitions and fixtures
  $dm.loadFixtureDefinitions("config\\FixtureDefinitions.xml")
  $dm.loadFixtures("config\\fixtures.xml")
  # test geting a fixture by name and print out its data
  f = $dm.getFixtureByName("Test1")
  puts "Fixture: " + f.name
  puts "\tBase Channel: " + f.baseChannel.to_s
  puts "\tNum Channels: " + f.numChannels.to_s
  puts "\tType: " + $dm.fixtureDefinitions.getFixtureDefinition(f.type).name
  puts "\tManufacturer: " + $dm.fixtureDefinitions.getFixtureDefinition(f.type).manufacturer
  puts "\tChannels:"
  f.getAllChannels.each do |channel|
    puts "\t\t" + channel.name
  end
  
  # set our defaults
  #   Dimmer to full, all others to 0
  $dm.setFixtureChannelValue("Test1", "Dimmer", 254) 
  $dm.setFixtureChannelValue("Test1", "Nil", 254)
  $dm.setFixtureChannelValue("Test1", "Red", 0)
  $dm.setFixtureChannelValue("Test1", "Green", 0)
  $dm.setFixtureChannelValue("Test1", "Blue", 0)
  
  $dm.setFixtureChannelValue("Test2", "Dimmer", 254)
  $dm.setFixtureChannelValue("Test2", "Nil", 254)
  $dm.setFixtureChannelValue("Test2", "Red", 0)
  $dm.setFixtureChannelValue("Test2", "Green", 0)
  $dm.setFixtureChannelValue("Test2", "Blue", 0)
  
  $dm.setFixtureChannelValue("Test3", "Dimmer", 254)
  $dm.setFixtureChannelValue("Test3", "Nil", 0)
  $dm.setFixtureChannelValue("Test3", "Red", 0)
  $dm.setFixtureChannelValue("Test3", "Green", 0)
  $dm.setFixtureChannelValue("Test3", "Blue", 0)
  
  # add a universe, and use the DmxUsbPro device
  # later we'll load this from a universes.xml or something
  $dm.addUniverse("Main", 0, DmxUsbPro::DmxProDevice.new())
  # print out our universes
  puts "Universes: "
  $dm.getAllUniverseNames().each do |name|
    puts "\t Universe: " + name
  end
  # connect to the universes output device
  $dm.connectUniverse("Main")
  if(!$dm.isUniverseConnected("Main"))
    puts "Error: Main universe did not connect : ["
    exit 1
  end

  
  # setup our color fades 
  @fades = Array.new()
  $dm.getAllFixtureNames().each do |fixtureName|
    $dm.setFixtureChannelValue(fixtureName, "Dimmer", 255)
    puts fixtureName
    @fades.push(ColorFade.new(fixtureName, "Red", 0, 0.05))
    @fades.push(ColorFade.new(fixtureName, "Blue", 128, 0.05))
    @fades.push(ColorFade.new(fixtureName, "Green", 254, 0.05))
  end
  
  # start our fades
  @fades.each do |fade|
    fade.start
  end
  
  # randomly set the speed of our fades every 5 seconds
  loop do
    sleep(5)
    @fades.each do |fade|
      fade.setSpeed(rand(0))
    end    
  end
end


