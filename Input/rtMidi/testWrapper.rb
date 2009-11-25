if __FILE__ == $0
  require 'rtMidiWrapper'
  include RtMidiLib
  
  midiIn = MidiInDevice.new()
  numDevices = midiIn.getNumDevices()
  if(numDevices == 0)
    puts "test failed. num devices == 0"
  end 
  puts "found #{numDevices} devices"
  
  # loop through each device
  deviceNames = midiIn.getDeviceNames()
  deviceNames.each do |name|
    puts name
  end
  
  puts 'connecting'
  midiIn.connect(0)
  (0..100000).each do |i|
    #puts i
    data = midiIn.getData()
    data.each_index do |index|
      puts "byte #{index} = #{data[index]}"
    end
    sleep(0.01)
  end
#  [0..numDevices].each do |i|
#    puts midiIn.getDeviceNames
    #midiIn.connect(i)
    #sleep(5)
    #data = midiIn.getData
    #puts data.to_s
    #midiIn.disconnect()
#  end
end