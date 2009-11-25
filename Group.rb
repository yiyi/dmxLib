module DmxLib
  
  class Group
    attr_reader :fixtures
    def initialize()
      @fixtures = Array.new
    end
    
    def addFixture(name)
      # make sure fixture does not already exist
      @fixtures.each do |f|
        if(f == name)
          return
        end
      end
      @fixtures.add(name)
    end
    
    def remFixtureByName(name)
      @fixtures.delete(name)
    end
    
    def getAllFixtures
      return @fixtures
    end
  end
end