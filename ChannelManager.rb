 require 'Channel'
module DmxLib
  class ChannelManager
    attr_reader :channels
    
    def initialize
      @channels = Hash.new
    end
    
    def addChannel(name, channel)
      if(@channels.has_key?(name))
        return
      end
      @channels[name] = channel
    end
    
    def remChannelByName(name)
      raise "remChannelByName not implemented"
    end
    
    def getChannelByName(name)
      if(@channels.has_key?(name))
        return @channels[name]
      else
        return nil
      end
    end
    
    def getAllChannels
      return @channels.values
    end
    
    def numChannels
      @channels.length
    end
    
    def getChannelUpdateFunc(channelName)
      channel = getChannelByName(channelName)
      return channel.getUpdateFunc
    end
  end
end
