if __FILE__ == $0

require 'DmxManager'
require 'FtdiWrapper'
include DmxLib

dm = DmxManager.new()
dm.loadFixtureDefinitions('config/FixtureDefinitions.xml')
dm.loadFixtures('config/fixtures.xml')
dm.getAllFixtureNames.each do |name|
  puts name
end

fixtureNames = dm.getAllFixtureNames
dm.addUniverse("Main", 0, FtdiLib::FtdiDevice.new())
puts "Universes: "
dm.getAllUniverseNames().each do |name|
  puts "\t Universe: " + name
end
#dm.connectUniverse("Main")
#if(!dm.isUniverseConnected("Main"))
#  puts "Error: Main universe did not connect : ["
#  exit 1
#end

fixtureNames.each do |fixtureName|
  dm.setFixtureChannelValue(fixtureName, "Dimmer", 255)
end

effects = Array.new
effectId = dm.addEffect('Random RGB Fade', fixtureNames, {:speed => 0.05, :step => 1})
dm.startEffect(effectId)
sleep(30)
dm.stopEffect(effectId)
sleep(30)
end