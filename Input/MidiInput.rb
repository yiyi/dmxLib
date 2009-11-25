module DmxLib
  require 'Input/Input'
  require 'rtMidiWrapper'
  include RtMidiLib
  
  class MidiCommand
    attr_reader :rawValue
    attr_reader :valueType
    
    def initialize(rawValue)
      @rawValue = rawValue
      case rawValue[0]
        when 0x80
          @valueType = "NoteOff"
        when 0x90
          @valueType = "NoteOn"
        when 0xA0
          @valueType = "Aftertouch"
        when 0xB0
          @valueType = "Continuous"
        when 0xC0
          @valueType = "PatchChange"
        when 0xD0
          @valueType = "ChannelPressure"
        when 0xE0
          @valueType = "PitchBend"
        else
          @valueType = "Other"
      end
    end
    
    def self.parseCommand(rawValue)
      @rawValue = rawValue
      case rawValue[0]
        when 0x80
          return NoteOff.new(rawValue)
        when 0x90
          return NoteOn.new(rawValue)
        when 0xA0
          return Aftertouch.new(rawValue)
        when 0xB0
          return Continuous.new(rawValue)
        when 0xC0
          return PatchChange.new(rawValue)
        when 0xD0
          return ChannelPressure.new(rawValue)
        when 0xE0
          return PitchBend.new(rawValue)
        else
          return nil
      end
    end
    
    def getChannel
    end
    
    def getValue
    end
  end
  
  class NoteOff < MidiCommand
    attr_reader :key
    attr_reader :velocity
    
    def initialize(rawValue)
      super(rawValue)
      @key = rawValue[1]
      @velocity = rawValue[2]
    end
    
    def getChannel
      return @key
    end
    
    def getValue
      return @velocity
    end
  end
  
  class NoteOn < MidiCommand
    attr_reader :key
    attr_reader :velocity
    
    def initialize(rawValue)
      super(rawValue)
      @key = rawValue[1]
      @velocity = rawValue[2]
    end
    
    def getChannel
      return @key
    end
    
    def getValue
      return @velocity
    end
  end  
  
  class Aftertouch < MidiCommand
    attr_reader :key
    attr_reader :touch
    
    def initialize(rawValue)
      super(rawValue)
      @key = rawValue[1]
      @touch = rawValue[2]
    end
    
    def getChannel
      return @key
    end
    
    def getValue
      return @touch
    end
  end
  
  class Continuous < MidiCommand
    attr_reader :controller
    attr_reader :value
    
    def initialize(rawValue)
      super(rawValue)
      @controller = rawValue[1]
      @value = rawValue[2]
    end
    
    def getChannel
      return @controller
    end
    
    def getValue
      return @value
    end
  end
  
  class PatchChange < MidiCommand
    attr_reader :instrument
    
    def initialize(rawValue)
      super(rawValue)
      @instrument = rawValue[1]
    end
    
    def getChannel
      return rawValue[0]
    end
    
    def getValue
      return @instrument
    end
  end
  
  class ChannelPressure < MidiCommand
    attr_reader :pressure
    
    def initialize(rawValue)
      super(rawValue)
      @pressure = rawValue[1]
    end
    
    def getChannel
      return rawValue[0]
    end
    
    def getValue
      return @velocity
    end
  end
  
  class PitchBend < MidiCommand
    attr_reader :msb
    attr_reader :lsb
    
    def initialize(rawValue)
      super(rawValue)
      @lsb = rawValue[1]
      @msb = rawValue[2]
    end
    
    def getChannel
      return rawValue[0]
    end
    
    def getValue
      return @lsb # just return the lowest significant bits (0 to 255)
    end
  end
  
  class MidiInput < Input
    def initialize()
      @inputType = "MidiInput"
      # parseParams(params)
      super()
      @midiIn = MidiIn.new()
    end
    
    def start()
      @midiIn.connect(@portIndex)     
      super()
    end

    def getData()
      data = @midiIn.getData()
      return data
    end
    
    def parseData(data)
      cmdArray = Array.new
      while(curData = data.shift)
        curCmd = nil
        case curData
          when 0x80
            curCmd = NoteOff.new([0x80, data.shift, data.shift])
          when 0x90
            curCmd = NoteOn.new([0x90, data.shift, data.shift])
          when 0xA0
            curCmd = Aftertouch.new([0xA0, data.shift, data.shift])
          when 0xB0
            curCmd = Continuous.new([0xB0, data.shift, data.shift])
          when 0xC0
            curCmd = PatchChange.new([0xC0, data.shift])
          when 0xD0
            curCmd = ChannelPressure.new([0xD0, data.shift])
          when 0xE0
            curCmd = PitchBend.new([0xE0, data.shift, data.shift])
          else
            curCmd = nil
        end
        
        cmdArray.push(curCmd) if curCmd != nil
      end
      return cmdArray
    end
    
    def update()
      data = getData()
      if(data != nil)
        command = MidiCommand.parseCommand(data)
        @mutex.synchronize do
          @channelData.push(command)
        end
      end
    end
    
    def stop()
      super()
    end
    
    def getDeviceNames()
      return @midiIn.getDeviceNames()
    end
    
    def getPortIndexByName(portName)
      devices = getDeviceNames()
      devices.each_index do |index|
        if(devices[index] == portName)
          return index
        end
      end
    end
    
    def setActiveDevice(deviceName)
      curRunning = isRunning
      stop if curRunning # stop if currently running
      
      portIndex = getPortIndexByName(value)
      @portIndex = portIndex if(portIndex != nil)
      start() if curRunning # restart if we were currently running
   end
  
    def parseParams(params)
      params.each do |key, value|
        case key
          when :deviceName # update the port
            curRunning = isRunning
            stop if curRunning # stop if currently running
            
            @portIndex = getPortIndexByName(value)
            
            start() if curRunning # restart if we were currently running
        end
      end
      super(params)
    end
    
    def getActiveChannel() # tries to determine the current channel user is touching and return it (or nil if no channel was touched
      stop()
      @thread = Thread.new() do 
        clearInputBuffer()
        x = 0
        lastCmd = nil
        while(x != 5 && lastCmd == nil)
          data = getData()
          if(data != nil)
            cmdArray = parseData(data)
            lastCmd = cmdArray.pop
          end
          x += 1
          sleep(0.5)
       end
     end
     start()
     return (lastCmd == nil) ? nil : lastCmd.channel
    end
    
#    def self.getDeviceNames #static version
#      m = MidiIn.new()
#      return m.getDeviceNames
#    end
  end
end