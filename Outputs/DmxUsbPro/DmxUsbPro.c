#include "ruby.h"
#include "ftd2xx.h"
#include "DmxUsbPro.h"

typedef struct _ftdiDevice
{
	BOOL IsConnected;
	FT_HANDLE ftHandle;
	unsigned char DmxData[513];
} FtdiDevice;

static VALUE rb_ftdiWrapper;
static VALUE rb_ftdiDevice;

static void
ftdi_mark (FtdiDevice *device)
{}

static void
ftdi_free (FtdiDevice *device)
{
  // TODO: close connection if connected
  free(device);
}

static VALUE 
ftdi_connect(VALUE self)
{
	FtdiDevice *device;
	FT_STATUS ftStatus;
    char Buf[64];
    FTDCB ftDCB;
	FT_HANDLE ftHandle;
	DWORD numDevs = 0;
	
	Data_Get_Struct (self, FtdiDevice, device);
	
	if(device->IsConnected == TRUE || device->ftHandle != NULL)
		return Qtrue;
	
	rb_warn("starting connect\n");
	
	ftStatus = FT_ListDevices((PVOID)&numDevs, NULL, FT_LIST_NUMBER_ONLY);
	if(ftStatus != FT_OK)
	{
		rb_warn("No devices");
		return Qfalse;
	}	
	ftStatus = FT_Open(0, &ftHandle);
	if(ftStatus != FT_OK)
	{
		rb_warn("Could not open device");
		return Qfalse;
	}
   
    rb_warn("succesfully opended device\n");
	
	// set tx/rx timeout values
	FT_SetTimeouts(ftHandle, 120, 100);
	FT_Purge (ftHandle, FT_PURGE_RX);
    
    device->ftHandle = ftHandle;
    device->IsConnected = TRUE;
    Sleep(1000L); // TODO: prolly shouldn't be blocking here?
	
    return Qtrue;
}

static VALUE ftdi_sendData(VALUE self)
{
	FtdiDevice *device;
	unsigned char end_code = DMX_END_CODE;
	FT_STATUS res = 0;
	DWORD bytes_to_write = 513; // includes start bit
	DWORD bytes_written = 0;
	HANDLE event = NULL;
	int size = 0;
	
		
	// Form Packet Header
	unsigned char header[DMX_HEADER_LENGTH];
	header[0] = DMX_START_CODE;
	header[1] = SET_DMX_TX_MODE;
	header[2] = bytes_to_write & OFFSET;
	header[3] = bytes_to_write >> BYTE_LENGTH;
	
	Data_Get_Struct (self, FtdiDevice, device);    

	if(!device->IsConnected || device->ftHandle == NULL)
		return Qfalse;
	
	// Write The Header
	res = FT_Write(	device->ftHandle, (unsigned char *)header, DMX_HEADER_LENGTH, &bytes_written);
	if (bytes_written != DMX_HEADER_LENGTH) 
		return  Qfalse;
	
	// Write The Data
	res = FT_Write(	device->ftHandle, (unsigned char *)device->DmxData, bytes_to_write, &bytes_written);
	if (bytes_written != bytes_to_write) 
		return  Qfalse;
	
	// Write End Code
	res = FT_Write( device->ftHandle, (unsigned char *)&end_code, ONE_BYTE, &bytes_written);
	if (bytes_written != ONE_BYTE) 
		return  Qfalse;
	
	if (res == FT_OK)
		return Qtrue;
	else
		return Qfalse; 
}

static VALUE ftdi_setChannelData(VALUE self, VALUE channel, VALUE value)
{
    FtdiDevice *device;
    Data_Get_Struct (self, FtdiDevice, device);
    // first byte is the start code, first channel starts at 1    
	device->DmxData[NUM2INT(channel) + 1] = NUM2INT(value);
	return Qtrue;
}

static VALUE ftdi_getChannelData(VALUE self, VALUE channel)
{
    FtdiDevice *device;
    Data_Get_Struct (self, FtdiDevice, device);    
    
    return (VALUE)INT2NUM(device->DmxData[NUM2INT(channel) + 1]);
}

static VALUE ftdi_disconnect(VALUE self)
{
    FtdiDevice *device;
    Data_Get_Struct (self, FtdiDevice, device);    

	if(device->ftHandle == NULL)
		return Qfalse;
	 FT_Close(device->ftHandle);
	 device->IsConnected = FALSE;
	 device->ftHandle = FALSE;
	 
	 return Qtrue;
}

static VALUE ftdi_isConnected(VALUE self)
{
    FtdiDevice *device;
    Data_Get_Struct (self, FtdiDevice, device);    
	
	return device->IsConnected ? Qtrue : Qfalse;
}

static VALUE ftdi_allocate(VALUE klass)
{	
	int x;
	FtdiDevice *device = ALLOC(FtdiDevice);
	device->IsConnected = FALSE;
	device->ftHandle = NULL;
	for(x = 0; x < 513; x++) 
	{
		device->DmxData[x] = 0;
	}
	return Data_Wrap_Struct(klass, ftdi_mark, ftdi_free, device);
}


void
Init_DmxUsbPro()
{
	rb_ftdiWrapper = rb_define_module("DmxUsbPro");
	rb_ftdiDevice = rb_define_class_under(rb_ftdiWrapper, "DmxProDevice", rb_cObject);
	rb_define_alloc_func(rb_ftdiDevice, ftdi_allocate);
	rb_define_method(rb_ftdiDevice, "connect", ftdi_connect, 0);
	rb_define_method(rb_ftdiDevice, "sendData", ftdi_sendData, 0);
	rb_define_method(rb_ftdiDevice, "setChannel", ftdi_setChannelData, 2);
	rb_define_method(rb_ftdiDevice, "getChannel", ftdi_getChannelData, 1);
	rb_define_method(rb_ftdiDevice, "disconnect", ftdi_disconnect, 0);
	rb_define_method(rb_ftdiDevice, "isConnected", ftdi_isConnected, 0);
}

