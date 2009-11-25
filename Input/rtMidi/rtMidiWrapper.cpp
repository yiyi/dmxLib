#include <iostream>
#include <cstdlib>

#include "RtMidi.h"
#include "RtError.h"


// need to undefine these so that this compiles. blah
#undef write
#undef read
#undef bind

#include "ruby.h"

static VALUE rb_rtMidiWrapper;
static VALUE rb_rtMidiIn;

static void rtMidiIn_mark (RtMidiIn *device)
{

}

static void rtMidiIn_free(RtMidiIn *device)
{
	delete device;
}

static VALUE rtMidiIn_allocate(VALUE klass)
{
	try {
		RtMidiIn *device = new RtMidiIn();
		return Data_Wrap_Struct(klass, rtMidiIn_mark, rtMidiIn_free, device);
	}
	catch(RtError &error)
	{
		rb_raise(rb_eRuntimeError, "error in allocate");
	}
}

static VALUE rtMidiIn_getNumDevices(VALUE self)
{
	RtMidiIn *device;
	Data_Get_Struct(self, RtMidiIn, device);
	return INT2NUM(device->getPortCount());
}

static VALUE rtMidiIn_getDeviceNames(VALUE self)
{
	RtMidiIn *device;
	Data_Get_Struct(self, RtMidiIn, device);
	VALUE devices = rb_ary_new();
	int numDevices = device->getPortCount();
	
	for(int x = 0; x < numDevices; x++)
	{
		rb_warn("trying port %i out of %x\n", x, numDevices);
		try {
			std::string portName = device->getPortName(x);
			rb_ary_push(devices, rb_str_new2(portName.c_str()));
		}
		catch(RtError &error)
		{
			rb_warn("could not get device name for port %i\n", x);
			return Qnil;
		}
	}
	return devices;
}

static VALUE rtMidiIn_connect(VALUE self, VALUE port)
{
	RtMidiIn *device;
	Data_Get_Struct(self, RtMidiIn, device);
	
	try {
		device->openPort(NUM2INT(port));
		device->ignoreTypes( false, false, false );
	}
	catch(RtError &error)
	{
		rb_warn("could not open port");
		return Qfalse;
	}
	
	return Qtrue;
}

static VALUE rtMidiIn_getData(VALUE self)
{
	RtMidiIn *device;
	Data_Get_Struct(self, RtMidiIn, device);

	std::vector<unsigned char> message;
	VALUE messages = rb_ary_new();
	try {
		double stamp = device->getMessage(&message);
		for(int x = 0; x < message.size(); x++)
		{
			rb_ary_push(messages, INT2FIX((int)message[x]));
		}
	}
	catch(RtError &error)
	{
		rb_warn("getData failed");
	}
	
	return messages;
}

void
Init_rtMidiWrapper()
{
	rb_rtMidiWrapper = rb_define_module("RtMidiLib");
	rb_rtMidiIn = rb_define_class_under(rb_rtMidiWrapper, "MidiInDevice", rb_cObject);
	rb_define_alloc_func(rb_rtMidiIn, rtMidiIn_allocate);
	rb_define_method(rb_rtMidiIn, "getNumDevices", RUBY_METHOD_FUNC(rtMidiIn_getNumDevices), 0);
	 
	rb_define_method(rb_rtMidiIn, "getDeviceNames", RUBY_METHOD_FUNC(rtMidiIn_getDeviceNames), 0);
	rb_define_method(rb_rtMidiIn, "connect", RUBY_METHOD_FUNC(rtMidiIn_connect), 1);
	//rb_define_method(rb_rtMidiIn, "disconnect", RUBY_METHOD_FUNC(rtMidiIn_disconnect), 0);
	rb_define_method(rb_rtMidiIn, "getData", RUBY_METHOD_FUNC(rtMidiIn_getData), 0);
		
	// later possibly support MidiOut
	//rb_rtMidiOut = rb_define_class_under(rb_rtMidiWrapper, "MidiOutDevice", rb_cObject);
}
;