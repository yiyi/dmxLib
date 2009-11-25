if __FILE__ == $0
  require 'DmxManager'

  require 'FtdiWrapper'

  include DmxLib

  class DmxMan
    @@dmxMan = nil
    def self.getDmxMan()
      if(@@dmxMan == nil)
        @@dmxMan = DmxLib::DmxManager.new
        
        debug "after dmxman"
        @@dmxMan.loadFixtureDefinitions("config\\FixtureDefinitions.xml")
        debug "after loadfd"
        @@dmxMan.loadFixtures("config\\fixtures.xml")
        debug "after loadf"
        @@dmxMan.addUniverse("Main", 0, FtdiLib::FtdiDevice.new())      
        debug "after adduni"
      end
      return @@dmxMan
    end
    
    def self.setDmxMan(dmxMan)
      @@dmxMan = dmxMan
    end
  end
  
  # classes for managing the effects display
  class Effectlink < Widget
    def initialize effectId, &block
      @effectId = effectId
      debug "building link"
      @control_stack = link("Delete") { |x|
        debug "stopping effect"
        @dmxManager.stopEffect @effectId
        x.parent.remove
      }
      super(&block)
    end
  end
  
  class Effectrow < Widget
    attr_reader :effect
    def initialize args, &block
      @effect = args[:effect]
      @effectDefinition = args[:effectDefinition]
      @control_stack = flow do
        border "#000000", :strokewidth => 1
        ed = @effect.getEffectDefinition
        para ed.name,  " | ", ed.className, " | ", 
          #effectlink(@effectId)
          link("delete") { |x| 
            debug "deleting"
            debug x.methods
            debug x.parent
            dmxManager = DmxMan.getDmxMan            
            dmxManager.remEffect(x.parent.parent.parent.effect.effectId)
            # x.parent.parent.parent.effect = nil
            x.parent.remove 
          }
      end
     
      instance_eval &block if block_given?
      super(&block)
    end
  end
  
  class Effecttable < Shoes::Widget
    def initialize &block
      #@row_sizes = args[:rows]
      @control_stack = stack
      dmxManager = DmxMan.getDmxMan
      debug "getting current running effects"
      runningEffects = dmxManager.getAllRunningEffects
      debug runningEffects
      runningEffects.each do |key, effect|
        debug "adding effect"
        addEffect(effect)   
      end
      instance_eval &block if block_given?
      super()
    end
    
    def row
      @control_stack.append do
        r = @control_stack.contents.size
        flow do
          @row_sizes.each_with_index { |w, c|
            stack :width => w do
              yield r, c if block_given?
            end
          }
        end
      end
    end
      
    def addEffect(effect)
      @control_stack.append do 
        effect = effectrow (:effect => effect) do 
          # para effect.name
        end        
      end
    end
  end
  
  
  class Test2 < Shoes
    url '/', :main
    url '/effects', :effects
    url '/fixtures', :fixtures
    
    def initialize()
      #@@dmxManager = DmxManager.new
      super()
    end
    
    def main
      @app = app
      topMenu(0)
      dmxManager = DmxMan.getDmxMan
#      if(@dmxManager == nil)
#        debug "new dmxmanager"
#        dmxManager = DmxLib::DmxManager.new
#        DmxMan.setDmxMan(dmxManager)
#        debug "after dmxman"
#        dmxManager.loadFixtureDefinitions("config\\FixtureDefinitions.xml")
#        debug "after loadfd"
#        dmxManager.loadFixtures("config\\fixtures.xml")
#        debug "after loadf"
#        dmxManager.addUniverse("Main", 0, FtdiLib::FtdiDevice.new())      
#        debug "after adduni"
#      end
      stack {
        @errorText = para ""
        flow {
          # universe stuffs
          debug "setting up listbox"
          @universeListBox = list_box( :border => 1,  :items => dmxManager.getAllUniverseNames)
          debug "after universe list"
          @connectUniverse = button "Connect Universe"
          @connectUniverse.click  {
            curSelectedUniverse = @universeListBox.text()
            debug "curUniverse: #{curSelectedUniverse}"
            return if(curSelectedUniverse == nil)
            begin
              debug "trying to connect"
              dmxManager.connectUniverse(curSelectedUniverse)
              debug "after connect"
            rescue
              @errorText.replace "Could not connect"
            end
          }
        }
      }
    end
      
    def effects
        debug 'setting up effectListbox'
        @app = app
        topMenu(1)
        dmxManager = DmxMan.getDmxMan()
        stack {
          flow {
            @effectListBox = list_box( :border => 1, :items => dmxManager.getEffectNames)
            debug 'after effectlistbox'
            @addEffect = button "Add Effect"
            @addEffect.click { 
              return if(@effectListBox.text == nil)
              effectId = dmxManager.addEffect(@effectListBox.text, dmxManager.getAllFixtureNames, {:speed => 0.05, :step => 1})
              dmxManager.startEffect(effectId)
              @curEffects.addEffect( dmxManager.getEffectById( effectId ) )
            }
          }
          debug 'setting up effects table'
          stack {
            @curEffects = effecttable  do # rebuild our table
            
            end
          }
       }
    end 
    
    def fixtures
      debug 'fixtures'
      @app = app
      topMenu(2)
      dmxManager = DmxMan.getDmxMan
    end
    
    def topMenu (tabNo)  # stolen from Morgan Prior's example (http://munkymorgy.blogspot.com)
      #Change settings here as required
      inactiveTabColor = "#B0B0B0"
      mainBodyColor    = "#D0D0D0"
      topColor         = "#E0E0E0"
      noOfTabs         = 3
      tabWidth         = 60
      tabHeight        = 30
      tabOverlay       = 8
      ##################################
      #Order and links of tabs
      names = Array.new

      names[0] = {:name=>"main",  :link=>"/"}
      names[1] = {:name => "effects", :link => "/effects"}
      names[2] = {:name => "fixtures", :link => "/fixtures"}
      ##################################
      
      background mainBodyColor
      #Make background for tabs a lighter colour
      background (topColor, :height=> (tabHeight-tabOverlay))

      #Add black line under tabs
      stroke black
      @app.line(0,(tabHeight-tabOverlay),@app.width(),(tabHeight-tabOverlay))
      
      #Do not alter calculations for tabs
      tabsSpace = @app.width() / (noOfTabs + 1)
      currentTabCentre = tabsSpace
      indentamount = Array.new
      #Loop and draw tabs
      (0... noOfTabs).each do |i|
         #Deactive tabs different colour
         if i == tabNo
            fill mainBodyColor
         else 
            fill inactiveTabColor
         end
         #Calculate position and size of tabs
         currentTabStart = currentTabCentre - (tabWidth/2)
         indentamount[i]  = currentTabStart
         @app.rect(currentTabStart,2,tabWidth, (tabHeight-2+5), :curve=>12)
         currentTabCentre  = currentTabCentre + tabsSpace
         
         #Add black line to the bottom of deactivated tabs
         if i != tabNo
            @app.line(currentTabStart,(tabHeight-8),(currentTabStart+tabWidth),(tabHeight-8))
         end
         
         #Set Tab Text Here
         @app.flow (:left => indentamount[i], :width => tabWidth) { 
           para (link(names[i][:name], :click=>names[i][:link],  :stroke => black, :underline => "none"), :align => "center")
         }
         
      end
      
      #Cover up the bottom of the tabs so they have square bottom
      fill   mainBodyColor
      stroke mainBodyColor
      @app.rect(0, (tabHeight-tabOverlay+1), @app.width(), (tabOverlay+4))
   
      #Put pen back to black
      stroke black
   end
  end
  
   Shoes.app :title => "Test2"

end