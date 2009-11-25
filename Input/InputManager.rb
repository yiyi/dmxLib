module DmxLib
  require 'Input/Input'
  require 'Input/MidiInput'
  
  class InputManager
    attr_reader :inputs
    
    def initialize()
      @inputs = Hash.new
    end
    
    def getInputTypes()
      return ('MidiInput')  
    end
    
    def addInput(name, inputType)
      return nil if(@inputs.has_key? name)
      case inputType
        when 'MidiInput'
          input = MidiInput.new()
          @inputs[name] = input
      end
    end
    
    def remInput(name)
      input = getInputByName(name)  
      input.stop
      input = nil
      @inputs.delete(name)
    end
    
    def getInputByName(name)
      input = @inputs.has_key?(name) ? @inputs[name] : nil
      raise "InputManager: No device by name #{name}" if input == nil
      return input
    end
    
    def getInputDeviceNames(name)
        input = getInputByName(name) 
        return input.getDeviceNames
    end
    
    def setInputActiveDevice(inputName, deviceName)
      input = getInputByName(inputName)
      input.setActiveDevice(deviceName)
    end
    
    def getInputActiveChannel(inputName)
      input = getInputByName(inputName)
      return input.getActiveChannel()
    end
    
    def addInputMap(inputName, inputMap)
      input = getInputByName(inputName)
      input.addInputMap(inputMap)
    end
  end
end