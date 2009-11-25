require 'DmxUsbPro'
require 'thread'

dm = DmxManager.new
f = DmxUsbPro::DmxProDevice.new
puts f.class
dm.addUniverse("Main", 0, f)
puts "Universes: "
dm.getAllUniverseNames().each do |name|
  puts "\t Universe: " + name
end
dm.connectUniverse("Main")

curVal = 0
rate = 40.0
ifd = ((1.0/rate)*1000) - 20
ifd = ifd/1000

puts "ifd: " + ifd.to_s
curVal = 0
values = Array.new
mutex = Mutex.new

for i in (0..512)
  values[i] = curVal  
  f.setChannel(i, curVal)
end

puts "ifd: " + ifd.to_s
puts "connected, sending data"

thread = Thread.new(f) do |device|
  loop do
    mutex.synchronize do
      f.sendData()
    end
    sleep(0.5)
  end
end


while(true)
	sleep(0.05)
  mutex.synchronize do
    for channel in (0..512) 
      curVal = f.getChannel(channel)
      curVal += 1
      if(curVal >= 255)
        curVal = 0
      end 
      f.setChannel(channel, curVal)
    end
  end
end 