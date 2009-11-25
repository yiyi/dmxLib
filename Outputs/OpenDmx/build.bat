ruby extconf.rb
nmake
mt -manifest ftdiWrapper.so.manifest -outputresource:ftdiWrapper.so;2
nmake install