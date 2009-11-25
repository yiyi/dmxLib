if __FILE__ == $0
  require 'mkmf'
  dir_config("FtdiWrapper")
  if have_library('FTD2XX', "FT_Open")
    create_makefile("FtdiWrapper")
  end
end