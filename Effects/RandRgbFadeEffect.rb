module DmxLib
  require 'Effect.rb'
  require 'EffectDefinition.rb'

  class RandRgbFadeEffect < Effect
   
    def self.register()
      params = Array.new()
      params.push(ParamDefinition.new("speed", 0, 254, "Time to sleep between updates"))
      params.push(ParamDefinition.new("rate", 1, 254, "Amount to increment between updates"))
      return (EffectDefinition.new('Random RGB Fade', 'RandRgbFadeEffect', "Randomly fade rgb values for fixtures", 1, params))
    end
    
    def getEffectDefinition
      return RandRgbFadeEffect.register()  
    end
    
    def initialize(dmxManager, fixtureNames, params)
      super(dmxManager, fixtureNames, params)
      setParams(params)
     
      @direction = 1
      @color = [rand(254), rand(254), rand(254)]
      puts @color
    end
  
    def update()
      @fixtureNames.each do |fixtureName|
        red = @dmxManager.getFixtureChannelValue(fixtureName, "Red")
        @color[0] = rand(254) if red == @color[0]
        green = @dmxManager.getFixtureChannelValue(fixtureName, "Green")
        @color[1] = rand(254) if (green == @color[1])
        blue = @dmxManager.getFixtureChannelValue(fixtureName, "Blue")
        @color[2] = rand(254) if (blue == @color[2])     
       
        (red > @color[0]) ? red -= @step : red += @step
        (green > @color[1]) ? green -= @step : green += @step
        (blue > @color[2]) ? blue -= @step : blue += @step
        puts "#{red} : #{green} : #{blue}"
        @dmxManager.setFixtureChannelValue(fixtureName, "Red", red)
        @dmxManager.setFixtureChannelValue(fixtureName, "Green", green)
        @dmxManager.setFixtureChannelValue(fixtureName, "Blue", blue)
        puts "done update"
      end
      puts @speed
      sleep(@speed)
    end
    
    def setParams(params)
      params.each do |key, value|
        case key
          when :speed
            puts "setting speed"
            @threadMutex.synchronize do
              @speed = value
            end
          when :step
            @threadMutex.synchronize do
              @step = value
            end
          else
            puts "could not find key"
        end
      end
    end
  end
end

