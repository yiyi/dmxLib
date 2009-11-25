#include "ruby.h"
#include "ftd2xx.h"

typedef struct _ftdiDevice
{
	BOOL IsConnected;
	FT_HANDLE ftHandle;
	unsigned char DmxData[512];
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
	    
	Data_Get_Struct (self, FtdiDevice, device);
	
	if(device->IsConnected == TRUE || device->ftHandle != NULL)
		return Qtrue;
	
	rb_warn("starting connect\n");
	ftStatus = FT_ListDevices(0,Buf,FT_LIST_BY_INDEX|FT_OPEN_BY_DESCRIPTION);
	ftHandle = FT_W32_CreateFile(Buf,GENERIC_READ|GENERIC_WRITE,0,0,
	    OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL | FT_OPEN_BY_DESCRIPTION,0);

	rb_warn("testing ftHandle\n");
    // connect to first device
    if (ftHandle == INVALID_HANDLE_VALUE) 
    {
		rb_warn("ftHandle invalid\n");
		//rb_raise("Could not connect to FTDI device");
        return Qfalse; 
        // TODO: handle error
     }
     rb_warn("ftHandle valid\n");
	if (FT_W32_GetCommState(ftHandle,&ftDCB)) {
		rb_warn("getcommstate passed\n");
        // FT_W32_GetCommState ok, device state is in ftDCB
        ftDCB.BaudRate = 250000;
        ftDCB.Parity = FT_PARITY_NONE;
        ftDCB.StopBits = FT_STOP_BITS_2;
        ftDCB.ByteSize = FT_BITS_8;
        ftDCB.fOutX = FALSE;
        ftDCB.fInX = FALSE;
        ftDCB.fErrorChar = FALSE;
        ftDCB.fBinary = TRUE;
        ftDCB.fRtsControl = FALSE;
        ftDCB.fAbortOnError = FALSE;

        if (!FT_W32_SetCommState(ftHandle,&ftDCB)) {
        	rb_warn("setcommstate failed\n");
        	// TODO: handle error
	        Sleep(1000L); // TODO: prolly shouldn't be blocking here?        	
	        //rb_raise("SetCommState failed");
            return Qfalse;
        }
    }
    else
    {
    	rb_warn("could not get comm state\n");
    	//rb_raise("GetCommState failed");
    }
    
    rb_warn("doing purge comm\n");
    FT_W32_PurgeComm(ftHandle,FT_PURGE_TX | FT_PURGE_RX);
    rb_warn("after purge comm\n");
    
    device->ftHandle = ftHandle;
    device->IsConnected = TRUE;
    Sleep(1000L); // TODO: prolly shouldn't be blocking here?

    FT_W32_EscapeCommFunction(device->ftHandle,CLRRTS);
    rb_warn("after escape comm\n");
	
    return Qtrue;
}

static VALUE ftdi_sendData(VALUE self)
{
	int x;
    ULONG bytesWritten;
    FtdiDevice *device;
    unsigned char StartCode = 0;
	
    Data_Get_Struct (self, FtdiDevice, device);    

	if(!device->IsConnected || device->ftHandle == NULL)
		return Qfalse;

/*
	for(x = 0; x < 512; x++)
	{
		rb_warn("data: %i : %i", x, device->DmxData[x]);
	}
*/
    FT_W32_SetCommBreak(device->ftHandle);
    FT_W32_ClearCommBreak (device->ftHandle);
    
    FT_W32_WriteFile(device->ftHandle, &StartCode, 1, &bytesWritten, NULL);
    FT_W32_WriteFile(device->ftHandle, device->DmxData, 512, &bytesWritten, NULL);

    return Qtrue;
}

static VALUE ftdi_setChannelData(VALUE self, VALUE channel, VALUE value)
{
    FtdiDevice *device;
    Data_Get_Struct (self, FtdiDevice, device);    
	//rb_warn("%i : %i", NUM2INT(channel), NUM2INT(value));
	device->DmxData[NUM2INT(channel)] = NUM2INT(value);
}

static VALUE ftdi_getChannelData(VALUE self, VALUE channel)
{
    FtdiDevice *device;
    Data_Get_Struct (self, FtdiDevice, device);    
    
    return (VALUE)INT2NUM(device->DmxData[NUM2INT(channel)]);
}

static VALUE ftdi_disconnect(VALUE self)
{
    FtdiDevice *device;
    Data_Get_Struct (self, FtdiDevice, device);    

	//if(device->IsConnected)
	//	return Qfalse;
	if(device->ftHandle == NULL)
		return Qfalse;
	 FT_W32_CloseHandle(device->ftHandle);
	 device->IsConnected = FALSE;
	 device->ftHandle = FALSE;
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
	for(x = 0; x < 512; x++)
	{
		device->DmxData[x] = 0;
	}
	return Data_Wrap_Struct(klass, ftdi_mark, ftdi_free, device);
}


void
Init_FtdiWrapper()
{
	rb_ftdiWrapper = rb_define_module("FtdiLib");
	rb_ftdiDevice = rb_define_class_under(rb_ftdiWrapper, "FtdiDevice", rb_cObject);
	rb_define_alloc_func(rb_ftdiDevice, ftdi_allocate);
	rb_define_method(rb_ftdiDevice, "connect", ftdi_connect, 0);
	rb_define_method(rb_ftdiDevice, "sendData", ftdi_sendData, 0);
	rb_define_method(rb_ftdiDevice, "setChannel", ftdi_setChannelData, 2);
	rb_define_method(rb_ftdiDevice, "getChannel", ftdi_getChannelData, 1);
	rb_define_method(rb_ftdiDevice, "disconnect", ftdi_disconnect, 0);
	rb_define_method(rb_ftdiDevice, "isConnected", ftdi_isConnected, 0);
}

