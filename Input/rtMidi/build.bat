ruby extconf.rb
nmake
mt -manifest rtMidiWrapper.so.manifest -outputresource:rtMidiWrapper.so;2
nmake install