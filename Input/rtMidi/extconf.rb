if __FILE__ == $0
  require 'mkmf'
  dir_config("rtMidi")
  if have_library('winmm') && 
    have_header('cstdio') 
    #find_header('RtError.h', '.') && 
    #find_header('RtMidi.h', ".")
    create_makefile("rtMidiWrapper")
  end
end