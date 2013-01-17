/*
 *  PTP-Win32.h
 *  StudioLightroom
 *
 *  Created by drake on 04/11/2009.
 *  Copyright 2009 Mountainstorm. All rights reserved.
 *
 */

#ifndef __PTP_WIN32
#define __PTP_WIN32


#include <windows.h>



#define ESCAPE_PTP_VENDOR_COMMAND	0x0100

#define PTP_MAX_PARAMS				5
#define PTP_NEXTPHASE_NO_DATA		5
#define PTP_NEXTPHASE_READ_DATA		3
#define PTP_NEXTPHASE_WRITE_DATA	4



#pragma pack( push, Old, 1 )

typedef struct _PTP_VENDOR_DATA_IN {
  WORD  OpCode;
  DWORD  SessionId;
  DWORD  TransactionId;
  DWORD  Params[PTP_MAX_PARAMS];
  DWORD  NumParams;
  DWORD  NextPhase;
  BYTE  VendorWriteData[1];
} PTP_VENDOR_DATA_IN, *PPTP_VENDOR_DATA_IN;



typedef struct _PTP_VENDOR_DATA_OUT {
  WORD  ResponseCode;
  DWORD  SessionId;
  DWORD  TransactionId;
  DWORD  Params[PTP_MAX_PARAMS];
  BYTE  VendorReadData[1];
}PTP_VENDOR_DATA_OUT, *PPTP_VENDOR_DATA_OUT;

#pragma pack( pop, Old )

#endif
