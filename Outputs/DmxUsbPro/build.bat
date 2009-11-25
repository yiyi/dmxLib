ruby extconf.rb --with-DmxUsbPro-dir=.
nmake
mt -manifest DmxUsbPro.so.manifest -outputresource:DmxUsbPro.so;2
nmake install