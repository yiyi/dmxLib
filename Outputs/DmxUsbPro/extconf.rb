if __FILE__ == $0
  require 'mkmf'
  dir_config("DmxUsbPro")
  have_header('FTD2XX.h')
  if have_library('FTD2XX', "FT_Open", "FTD2XX.h")
    create_makefile("DmxUsbPro")
  end
end