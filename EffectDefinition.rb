
module DmxLib
 
  class ParamDefinition
    attr_reader :name
    attr_reader :minValue
    attr_reader :maxValue
    attr_reader :description
    
    def initialize(name, minValue, maxValue, description)
      @name = name
      @minValue = minValue
      @maxValue = maxValue
      @description = description
    end
  end
  
  class EffectDefinition
    attr_reader :name
    attr_reader :className
    attr_reader :parameters
    attr_reader :description
    attr_reader :version
    def initialize(name, className, description, version, parameters)
      @name = name
      @className = className
      @description = @description
      @version = version
      @parameters = parameters
    end
  end
end