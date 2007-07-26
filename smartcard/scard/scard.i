/*==============================================================================
Copyright 2001-2007 gemalto
Author: Jean-Daniel Aussel, mailto:jean-daniel.aussel@gemalto.com

This file is part of pyscard.

pyscard is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

pyscard is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with pyscard; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
==============================================================================*/

%define DOCSTRING
"The smartcard.scard module is a simple wrapper on top of the C language
PCSC SCardXXX API.

The smartcard.scard module is the lower layer of the pyscard
framework that provides a higher level interface.

You should avoid using the smartcard.scard package directly, and use the
pyscard directly because:

. smartcard.scard being a C wrapper, the code tends to look like C code
written in python syntax

. the smartcard package provides higher level abstractions (e.g.  CardType,
CardConnection), and makes programming easier since it is totally written
in Python

You can still use the smartcard.scard package if you want to write your
own framework, or if you want to perform quick-and-dirty port of C
language programs using SCardXXX calls, or if there are features of
SCardXXX API that you want to use and that are not available in the
pyscard library.

Introduction

The smartcard.scard module is a Python wrapper around PCSC smart card base 
services.  On Windows, the wrapper is performed around the smart card base 
components winscard library.  On linux, the wrapper is performed around 
PCSC-lite library.  


On Windows using the smart card base components, the smartcard.scard 
module provides mapping for the following API functions: 

SCardAddReaderToGroup
SCardBeginTransaction
SCardCancel
SCardConnect
SCardDisconnect
SCardEndTransaction
SCardEstablishContext
SCardForgetCardType
SCardForgetReader
SCardForgetReaderGroup
SCardGetAttrib
SCardGetCardTypeProviderName
SCardGetErrorMessage
SCardGetStatusChange
SCardIntroduceCardType
SCardIntroduceReader
SCardIntroduceReaderGroup
SCardIsValidContext
SCardListInterfaces
SCardListCards
SCardListReaders
SCardListReaderGroups
SCardLocateCards
SCardReconnect
SCardReleaseContext
SCardRemoveReaderFromGroup
SCardStatus
SCardTransmit

On linux with PCSC lite, the smartcard.scard module provides mapping for the following API functions:

SCardBeginTransaction
SCardConnect
SCardDisconnect
SCardEndTransaction
SCardEstablishContext
SCardGetAttrib
SCardGetStatusChange
SCardListReaders
SCardListReaderGroups
SCardReconnect
SCardReleaseContext
SCardStatus
SCardTransmit

The following PCSC smart card functions are not wrapped by the scard module on any platform:

GetOpenCardName
SCardControl
SCardFreeMemory
SCardGetProviderId
SCardSetCartTypeProviderName
SCardUIDlgSelectCard

Comments, bugs, improvements welcome.

-------------------------------------------------------------------------------
Copyright 2001-2007 gemalto
Author: Jean-Daniel Aussel, mailto:jean-daniel.aussel@gemalto.com

This file is part of pyscard.

pyscard is free software; you can redistribute it and/or modify it 
under the terms of the GNU Lesser General Public License as published by 
the Free Software Foundation; either version 2.1 of the License, or (at 
your option) any later version.  

pyscard is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public 
License for more details.  

You should have received a copy of the GNU Lesser General Public License 
along with pyscard; if not, write to the Free Software Foundation, 
Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA 

"
%enddef

%module( docstring=DOCSTRING, package="smartcard.scard") scard

%feature("autodoc", "3" );

%{
#ifdef WIN32
#include <windows.h>
#endif

#ifdef __APPLE__
#include <PCSC/winscard.h>
#else
#include <winscard.h>
#endif

#ifdef PCSCLITE
    #ifdef __APPLE__
        //#include <PCSC/reader.h>
    #else
        #include <reader.h>
    #endif
#endif //PCSCLITE

#include "helpers.h"
#include "memlog.h"

#include "winscarddll.h"

%}

%include typemaps.i
%include PcscTypemaps.i

%{

#ifdef WIN32
///////////////////////////////////////////////////////////////////////////////
long _AddReaderToGroup(
  unsigned long hContext,
  char* szReaderName,
  char* szGroupName )
{
    winscard_init();
    return (mySCardAddReaderToGroupA)(
                         hContext,
                         szReaderName,
                         szGroupName );
}

///////////////////////////////////////////////////////////////////////////////
long _Cancel( unsigned long hContext )
{
    winscard_init();
    return (mySCardCancel)( hContext );
}

///////////////////////////////////////////////////////////////////////////////
long _ForgetCardType( unsigned long hContext, char* pszCardName )
{
    winscard_init();
    return (mySCardForgetCardTypeA)( hContext, pszCardName );
}

///////////////////////////////////////////////////////////////////////////////
long _ForgetReader( unsigned long hContext, char* szReaderName )
{
    winscard_init();
    return (mySCardForgetReaderA)( hContext, szReaderName );
}

///////////////////////////////////////////////////////////////////////////////
long _ForgetReaderGroup( unsigned long hContext, char* szGroupName )
{
    winscard_init();
    return (mySCardForgetReaderGroupA)( hContext, szGroupName );
}

///////////////////////////////////////////////////////////////////////////////
long _GetCardTypeProviderName(
    unsigned long hContext,
    char* pszCardName,
    unsigned long dwProviderId,
    STRING* psl )
{
    long lRetCode;
    unsigned long cchProviderName=SCARD_AUTOALLOCATE;

    winscard_init();

    // autoallocate memory; will be freed on output typemap
    psl->hcontext=hContext;
    psl->sz=NULL;

    lRetCode=(mySCardGetCardTypeProviderNameA)(
        hContext, pszCardName, dwProviderId, (LPTSTR)&psl->sz, &cchProviderName );

    return lRetCode;
};

///////////////////////////////////////////////////////////////////////////////
long _IntroduceCardType(
  unsigned long hContext,
  char* pszCardName,
  GUIDLIST* pguidPrimaryProvider,
  GUIDLIST* rgguidInterfaces,
  BYTELIST* pbAtr,
  BYTELIST* pbAtrMask
)
{
    winscard_init();
    return (mySCardIntroduceCardTypeA)(
                hContext,
                pszCardName,
                pguidPrimaryProvider ? pguidPrimaryProvider->aguid : NULL,
                rgguidInterfaces ? rgguidInterfaces->aguid : NULL,
                rgguidInterfaces ? rgguidInterfaces->cGuids : 0,
                pbAtr->ab,
                pbAtrMask->ab,
                pbAtr->cBytes );
}

///////////////////////////////////////////////////////////////////////////////
long _IntroduceReader( unsigned long hcontext, char* szReaderName, char* szDeviceName )
{
    winscard_init();
    return (mySCardIntroduceReaderA)( hcontext, szReaderName, szDeviceName );
}

///////////////////////////////////////////////////////////////////////////////
long _IntroduceReaderGroup( unsigned long hcontext, char* szGroupName )
{
    winscard_init();
    return (mySCardIntroduceReaderGroupA)( hcontext, szGroupName );
}

///////////////////////////////////////////////////////////////////////////////
long _IsValidContext( unsigned long hContext )
{
    winscard_init();
    return (mySCardIsValidContext)( hContext );
}

///////////////////////////////////////////////////////////////////////////////
long _ListCards( unsigned long hContext, BYTELIST* pbl, GUIDLIST* guidlist, STRINGLIST* pmszCards )
{
    // autoallocate memory; will be freed on output typemap
    unsigned long cchCards=SCARD_AUTOALLOCATE;

    winscard_init();
    pmszCards->ac=NULL;
    pmszCards->hcontext=hContext;

    //SCardHelper_PrintByteList( pbl );
    return (mySCardListCardsA)(
        hContext,
        pbl->ab,
        (NULL==guidlist) ? NULL : guidlist->aguid,
        (NULL==guidlist) ? 0 : guidlist->cGuids,
        (LPTSTR)&pmszCards->ac,
        &cchCards );
};


///////////////////////////////////////////////////////////////////////////////
long _ListInterfaces(
    unsigned long hContext,
    char* pszCard,
    GUIDLIST* pgl
)
{
    long lRetCode;

    winscard_init();

    pgl->cGuids = SCARD_AUTOALLOCATE;
    pgl->hcontext = hContext;
    pgl->aguid = NULL;

    lRetCode = (mySCardListInterfacesA)( hContext, pszCard, (LPGUID)&pgl->aguid, &pgl->cGuids );
    if( lRetCode!=SCARD_S_SUCCESS )
    {
        pgl->cGuids=0;
    }
    return lRetCode;
}

///////////////////////////////////////////////////////////////////////////////
long _LocateCards(
  unsigned long hContext,
  STRINGLIST* mszCards,
  READERSTATELIST* prl
)
{
    LPCSTR pcstr=(0==strlen((LPCTSTR)mszCards->ac)) ? NULL : (LPCTSTR)mszCards->ac;

    winscard_init();

    return (mySCardLocateCardsA)(
                hContext,
                pcstr,
                prl->ars,
                prl->cRStates );
}

///////////////////////////////////////////////////////////////////////////////
long _RemoveReaderFromGroup(
  unsigned long hContext,
  char* szReaderName,
  char* szGroupName )
{
    winscard_init();
    return (mySCardRemoveReaderFromGroupA)(
                         hContext,
                         szReaderName,
                         szGroupName );
}

#endif // WIN32

///////////////////////////////////////////////////////////////////////////////
long _BeginTransaction( unsigned long hCard )
{
    winscard_init();
    return (mySCardBeginTransaction)( hCard );
}

///////////////////////////////////////////////////////////////////////////////
long _Connect(
  unsigned long hContext,
  char* szReader,
  unsigned long dwShareMode,
  unsigned long dwPreferredProtocols,
  unsigned long* phCard,
  unsigned long* pdwActiveProtocol )
{
    winscard_init();
    return (mySCardConnectA)(
            hContext,
            (LPCTSTR)szReader,
            dwShareMode,
            dwPreferredProtocols,
            phCard,
            pdwActiveProtocol );
}

///////////////////////////////////////////////////////////////////////////////
long _Disconnect( unsigned long hCard, unsigned long dwDisposition )
{
    winscard_init();
    return (mySCardDisconnect)( hCard, dwDisposition );
}

///////////////////////////////////////////////////////////////////////////////
long _EndTransaction( unsigned long hCard, unsigned long dwDisposition )
{
    winscard_init();
    return (mySCardEndTransaction)( hCard, dwDisposition );
}

///////////////////////////////////////////////////////////////////////////////
long _EstablishContext( unsigned long dwScope, unsigned long* phContext )
{
    winscard_init();
    return (mySCardEstablishContext)( dwScope, NULL, NULL, phContext );
}

///////////////////////////////////////////////////////////////////////////////
long _GetAttrib( unsigned long hcard, unsigned long dwAttrId, BYTELIST* pbl )
{
    long lRetCode;

    winscard_init();

    pbl->cBytes = 0;
    pbl->ab = NULL;

    lRetCode = (mySCardGetAttrib)( hcard, dwAttrId, pbl->ab, &pbl->cBytes );
    if( (lRetCode!=SCARD_S_SUCCESS) || (pbl->cBytes<1) )
    {
        return lRetCode;
    }

    pbl->ab = (unsigned char*)mem_Malloc(pbl->cBytes*sizeof(unsigned char));
    if (pbl->ab==NULL)
    {
        return SCARD_E_NO_MEMORY;
    }

    lRetCode = (mySCardGetAttrib)( hcard, dwAttrId, pbl->ab, &pbl->cBytes );
    return lRetCode;
}

///////////////////////////////////////////////////////////////////////////////
long _GetStatusChange(
    unsigned long hContext,
    unsigned long dwTimeout,
    READERSTATELIST* prsl )
{
    long hresult=SCARD_E_NO_READERS_AVAILABLE;
    winscard_init();

    __try
    {
        hresult=(mySCardGetStatusChangeA)( hContext, dwTimeout, prsl->ars, prsl->cRStates );
    }
    __except( EXCEPTION_EXECUTE_HANDLER )
    {
        hresult=SCARD_E_NO_READERS_AVAILABLE;
        prsl=NULL;
    }
    //return (mySCardGetStatusChangeA)( hContext, dwTimeout, prsl->ars, prsl->cRStates );
    return hresult;
}

///////////////////////////////////////////////////////////////////////////////
long _ListReaders(
    unsigned long hContext,
    STRINGLIST* pmszGroups,
    STRINGLIST* pmszReaders )
{
    LPCTSTR mszGroups;
    unsigned long cchReaders;
    LONG lRetCode;

    winscard_init();

    if(pmszGroups)
    {
        mszGroups=pmszGroups->ac;
    }
    else
    {
        mszGroups=NULL;
    }

    #ifdef NOAUTOALLOCATE
        // autoallocate memory; will be freed on output typemap
        cchReaders=SCARD_AUTOALLOCATE;

        pmszReaders->ac=NULL;
        pmszReaders->hcontext=hContext;

        return (mySCardListReadersA)( hContext, mszGroups, (LPTSTR)&pmszReaders->ac, &cchReaders );
    #endif //AUTOALLOCATE

    // no autoallocate on pcsc-lite; do a first call to get length
    // then allocate memory and do a final call
    #ifndef NOAUTOALLOCATE
        // set hcontext to 0 so that mem_Free will
        // be called instead of SCardFreeMemory
        pmszReaders->hcontext=0;
        pmszReaders->ac=NULL;
        cchReaders=0;
        lRetCode = (mySCardListReadersA)( hContext, mszGroups, NULL, &cchReaders );
        if ( SCARD_S_SUCCESS!=lRetCode )
        {
            return lRetCode;
        }

        if( 0==cchReaders )
        {
            return SCARD_S_SUCCESS;
        }

        pmszReaders->ac=mem_Malloc( cchReaders*sizeof( char ) );
        if ( NULL==pmszReaders->ac )
        {
            return SCARD_E_NO_MEMORY;
        }

        return (mySCardListReadersA)( hContext, mszGroups, (LPTSTR)pmszReaders->ac, &cchReaders );
    #endif // !NOAUTOALLOCATE

}

///////////////////////////////////////////////////////////////////////////////
long _ListReaderGroups( unsigned long hContext, STRINGLIST* pmszReaderGroups )
{
    DWORD cchReaderGroups;
    LONG lRetCode;

    winscard_init();

    #ifdef NOAUTOALLOCATE
        cchReaderGroups = SCARD_AUTOALLOCATE;
        pmszReaderGroups->ac=NULL;
        pmszReaderGroups->hcontext=hContext;

        return (mySCardListReaderGroupsA)( hContext, (LPTSTR)&pmszReaderGroups->ac, &cchReaderGroups );
    #endif // NOAUTOALLOCATE

    // no autoallocate on pcsc-lite; do a first call to get length
    // then allocate memory and do a final call
    #ifndef NOAUTOALLOCATE
        // set hcontext to 0 so that mem_Free will
        // be called instead of SCardFreeMemory

        pmszReaderGroups->hcontext=0;
        cchReaderGroups = 0;
        pmszReaderGroups->ac=NULL;
        lRetCode = (mySCardListReaderGroupsA)( hContext, (LPTSTR)pmszReaderGroups->ac, &cchReaderGroups );
        if ( SCARD_S_SUCCESS!=lRetCode )
        {
            return lRetCode;
        }

        if( 0==cchReaderGroups )
        {
            return SCARD_S_SUCCESS;
        }

        pmszReaderGroups->ac=mem_Malloc( cchReaderGroups*sizeof( char ) );
        if ( NULL==pmszReaderGroups->ac )
        {
            return SCARD_E_NO_MEMORY;
        }

        return (mySCardListReaderGroupsA)( hContext, (LPTSTR)pmszReaderGroups->ac, &cchReaderGroups );
    #endif // !NOAUTOALLOCATE
};


///////////////////////////////////////////////////////////////////////////////
long _Reconnect(
    unsigned long hCard,
    unsigned long dwShareMode,
    unsigned long dwPreferredProtocols,
    unsigned long dwInitialization,
    unsigned long* pdwActiveProtocol
)
{
    winscard_init();

    return (mySCardReconnect)(
                               hCard,
                               dwShareMode,
                               dwPreferredProtocols,
                               dwInitialization,
                               pdwActiveProtocol );
}

///////////////////////////////////////////////////////////////////////////////
long _ReleaseContext( unsigned long hContext )
{
    winscard_init();
    return (mySCardReleaseContext)( hContext );
}

///////////////////////////////////////////////////////////////////////////////
long _Status(
  unsigned long hCard,
  STRINGLIST*  pszReaderName,
  unsigned long* pdwState,
  unsigned long* pdwProtocol,
  BYTELIST* pbl
)
{
    long lRetCode;
    DWORD dwReaderLen=256;
    DWORD dwAtrLen=32;

    winscard_init();
    for(;;)
    {
        pbl->ab = (unsigned char*)mem_Malloc(dwAtrLen*sizeof(unsigned char));
        if( pbl->ab == NULL )
        {
            lRetCode=SCARD_E_NO_MEMORY;
            break;
        }
        pbl->cBytes = dwAtrLen;
        pszReaderName->ac = mem_Malloc(dwReaderLen*sizeof(char));
        if( pszReaderName->ac == NULL )
        {
            lRetCode=SCARD_E_NO_MEMORY;
            break;
        }
        pszReaderName->hcontext = 0;
        lRetCode = (mySCardStatusA)(
            hCard,
            (LPTSTR)pszReaderName->ac,
            &dwReaderLen,
            pdwState,
            pdwProtocol,
            pbl->ab,
            &pbl->cBytes );
        break;
    }

    return lRetCode;
}

///////////////////////////////////////////////////////////////////////////////
long _Transmit(
  unsigned long hCard,
  unsigned long pioSendPci,
  BYTELIST* pblSendBuffer,
  BYTELIST* pblRecvBuffer
)
{
    PSCARD_IO_REQUEST piorequest=NULL;

    winscard_init();

    pblRecvBuffer->ab = (unsigned char*)mem_Malloc(1024*sizeof(unsigned char));
    pblRecvBuffer->cBytes=1024;

    // keep in sync with redefinition in PcscDefs.i
    switch(pioSendPci)
    {
        case 0x01:
            piorequest=(PSCARD_IO_REQUEST)myg_prgSCardT0Pci;
            break;

        case 0x02:
            piorequest=(PSCARD_IO_REQUEST)myg_prgSCardT1Pci;
            break;

        case 0x04:
            piorequest=(PSCARD_IO_REQUEST)myg_prgSCardRawPci;
            break;

        default:
            return SCARD_E_INVALID_PARAMETER;

    }
    return (mySCardTransmit)(
                hCard,
                (PSCARD_IO_REQUEST)piorequest,
                //SCARD_PCI_T0,
                pblSendBuffer->ab,
                pblSendBuffer->cBytes,
                NULL,
                pblRecvBuffer->ab,
                &pblRecvBuffer->cBytes );
}

ERRORSTRING* _GetErrorMessage( long lErrCode )
{
    #ifdef WIN32
    #define _NO_SERVICE_MSG     "The Smart card resource manager is not running."

        DWORD dwRetCode;
        LPVOID ppszError;

        dwRetCode=FormatMessage(
            FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_MAX_WIDTH_MASK,
            NULL,
            lErrCode,
            MAKELANGID( LANG_NEUTRAL, SUBLANG_DEFAULT ),
            (LPTSTR)&ppszError,
            0,
            NULL );

        if( 0L==dwRetCode )
        {
            ppszError=NULL;
            if( SCARD_E_NO_SERVICE==lErrCode )
            {
                ppszError=(LPVOID)LocalAlloc( LPTR, sizeof( _NO_SERVICE_MSG )+1 );
                if(NULL!=ppszError)
                {
                    strncpy( ppszError, _NO_SERVICE_MSG, sizeof( _NO_SERVICE_MSG )+1 );
                }
            }
        }

        return ppszError;
    #endif // WIN32
    #ifdef PCSCLITE
        return (ERRORSTRING*)pcsc_stringify_error( lErrCode );
    #endif // PCSCLITE
}

%}

//
// a few documentation typemaps
//
%typemap(doc, name="hCard", type="unsigned long") (unsigned long hCard) "hCard: card handle return from SCardConnect()";
%typemap(doc, name="hContext", type="unsigned long") (unsigned long hContext) "hContext: context handle return from SCardEstablishContext()";
%typemap(doc, name="groupname", type="string") (char* szGroupName) "groupname: card reader group name";
%typemap(doc, name="readername", type="string") (char* szReaderName) "readername: card reader name";
%typemap(doc, name="cardname", type="string") (char* szCardName) "cardname: friendly name of a card";
%typemap(doc, name="readerstate", type="tuple") (READERSTATELIST *BOTH) "readerstate: state tuple (readername, state, atr)";
%typemap(doc, name="devicename", type="string") (char* szDeviceName) "devicename: card reader device name";
%typemap(doc, name="guidlist", type="list") (GUIDLIST* OUTPUT) "guidlist: in output, a list of GUID";
%typemap(doc, name="guidlist_in", type="list") (GUIDLIST* INPUT) "guidlist_in: in input, a list of GUID";
%typemap(doc, name="disposition", type="unsigned long") (unsigned long dwDisposition) "disposition: a disposition flag";
%typemap(doc, name="dwScope", type="unsigned long") (unsigned long dwScope) "dwScope: context scope";
%typemap(doc, name="dwAttrId", type="unsigned long") (unsigned long dwAttrId) "dwAttrId: value of attribute to get";
%typemap(doc, name="dwTimeout", type="unsigned long") (unsigned long dwTimeout) "dwTimeout: timeout value";


#ifdef WIN32
///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_ADDREADERTOGROUP
"
adds a reader to a reader group

Windows only, not supported by PCSC lite wrapper.

example:

from smartcard.scard import *
... establish context ...
    newgroup = 'SCard$MyOwnGroup'
    reader = 'SchlumbergerSema Reflex USB v.2 0'
    readeralias = 'SchlumbergerSema Reflex USB v.2 0 alias'
    hresult = SCardIntroduceReader( hcontext, readeralias, reader] )
    if hresult!=0:
        raise error, 'Unable to introduce reader: ' + SCardGetErrorMessage(hresult)

    hresult = SCardAddReaderToGroup( hcontext, readeralias, newgroup )
    if hresult!=0:
        raise error, 'Unable to add reader to group: ' + SCardGetErrorMessage(hresult)

...
"
%enddef
%feature("docstring") DOCSTRING_ADDREADERTOGROUP;
%rename(SCardAddReaderToGroup) _AddReaderToGroup(
  unsigned long hContext,
  char* szReaderName,
  char* szGroupName );
long _AddReaderToGroup(
  unsigned long hContext,
  char* szReaderName,
  char* szGroupName );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_CANCEL
"
This function cancels all pending blocking requests on the ScardGetStatusChange() function.

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
... establish context ...
hresult = SCardCancel( hcard )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'failed to cancel pending actions: ' + SCardGetErrorMessage(hresult)
..."
%enddef
%feature("docstring") DOCSTRING_CANCEL;
%rename(SCardCancel) _Cancel( unsigned long hContext );
long _Cancel( unsigned long hContext );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_FORGETCARDTYPE
"
removes an introduced smart card from the smart card subsystem.

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
... establish context ...
hresult = SCardForgetCardType( hcontext, 'myCardName' )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failed to remove card type: ' + SCardGetErrorMessage(hresult)
...

"
%enddef
%feature("docstring") DOCSTRING_FORGETCARDTYPE;
%rename(SCardForgetCardType) _ForgetCardType( unsigned long hContext, char* pszCardName );
long _ForgetCardType( unsigned long hContext, char* pszCardName );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_FORGETREADER
"
Removes a previously introduced smart card reader from the smart
card subsystem.

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
... establish context ...
...
hresult = SCardForgetReader( hcontext, dummyreader )
if hresult!=0:
    raise error, 'Failed to forget readers ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_FORGETREADER;
%rename(SCardForgetReader) _ForgetReader( unsigned long hContext, char* szReaderName );
long _ForgetReader( unsigned long hContext, char* szReaderName );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_FORGETREADERGROUP
"
Removes a previously introduced smart card reader group from the smart
card subsystem. Although this function automatically clears all readers
from the group, it does not affect the existence of the individual readers
in the database.

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
... establish context ...
...
hresult = SCardForgetReaderGroup( hcontext, newgroup )
if hresult!=0:
    raise error, 'Unable to forget reader group: ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_FORGETREADERGROUP;
%rename(SCardForgetReaderGroup) _ForgetReaderGroup( unsigned long hContext, char* szGroupName );
long _ForgetReaderGroup( unsigned long hContext, char* szGroupName );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_GETCARDTYPEPROVIDERNAME
"
Returns the name of the module (dynamic link library) containing the provider for a
given card name and provider type.

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
... establish context ...
hresult, cards = SCardListCards( hcontext, [], [] )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failure to list cards: ' + SCardGetErrorMessage(hresult)
for i in cards:
    hresult, providername = SCardGetCardTypeProviderName(
                                hcontext,   i, SCARD_PROVIDER_PRIMARY )
    if hresult==0:
         print providername
    hresult, providername = SCardGetCardTypeProviderName(
                                hcontext,   i, SCARD_PROVIDER_CSP )
    if hresult==0:
         print providername
...
"
%enddef
%feature("docstring") DOCSTRING_GETCARDTYPEPROVIDERNAME;
%rename(SCardGetCardTypeProviderName) _GetCardTypeProviderName(
  unsigned long hContext,
  char* szCardName,
  unsigned long dwProviderId,
  STRING* OUTPUT
);
long _GetCardTypeProviderName(
  unsigned long hContext,
  char* szCardName,
  unsigned long dwProviderId,
  STRING* OUTPUT
);

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_INTRODUCECARDTYPE
"
Introduces a smart card to the smart card subsystem (for the active user)
by adding it to the smart card database.

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
...
znewcardName = 'dummy-card'
znewcardATR = [0x3B, 0x77, 0x94, 0x00, 0x00, 0x82, 0x30, 0x00, 0x13, 0x6C, 0x9F, 0x22]
znewcardMask= [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
znewcardPrimGuid = smartcard.guid.strToGUID('{128F3806-4F70-4ccf-977A-60C390664840}')
znewcardSecGuid = smartcard.guid.strToGUID('{EB7F69EA-BA20-47d0-8C50-11CFDEB63BBE}')
...
       hresult = SCardIntroduceCardType( hcontext, znewcardName, znewcardPrimGuid,
                                         znewcardPrimGuid + znewcardSecGuid, znewcardATR, znewcardMask )
       if hresult!=0:
           raise error, 'Failed to introduce card type: ' + SCardGetErrorMessage(hresult)
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failed to introduce card type: ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_INTRODUCECARDTYPE;
%rename(SCardIntroduceCardType) _IntroduceCardType(
  unsigned long hContext,
  char* pszCardName,
  GUIDLIST* INPUT,
  GUIDLIST* INPUT,
  BYTELIST* INPUT,
  BYTELIST* INPUT
);
long _IntroduceCardType(
  unsigned long hContext,
  char* pszCardName,
  GUIDLIST* INPUT,
  GUIDLIST* INPUT,
  BYTELIST* INPUT,
  BYTELIST* INPUT
);

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_INTRODUCEREADER
"
Introduces a reader to the smart card subsystem.

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
...
dummyreader = readers[0] + ' dummy'
hresult = SCardIntroduceReader( hcontext, dummyreader, readers[0] )
if hresult!=0:
    raise error, 'Unable to introduce reader: ' + dummyreader + ' : ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_INTRODUCEREADER;
%rename(SCardIntroduceReader) _IntroduceReader( unsigned long hcontext, char* szReaderName, char* szDeviceName );
long _IntroduceReader( unsigned long hcontext, char* szReaderName, char* szDeviceName );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_INTRODUCEREADERGROUP
"
Introduces a reader group to the smart card subsystem. However, the
reader group is not created until the group is specified when adding
a reader to the smart card database.

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult = SCardIntroduceReaderGroup( hcontext, 'SCard$MyOwnGroup' )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Unable to introduce reader group: ' + SCardGetErrorMessage(hresult)
hresult = SCardAddReaderToGroup( hcontext, 'SchlumbergerSema Reflex USB v.2 0', 'SCard$MyOwnGroup' )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Unable to add reader to group: ' + SCardGetErrorMessage(hresult)
"
%enddef
%feature("docstring") DOCSTRING_INTRODUCEREADERGROUP;
%rename(SCardIntroduceReaderGroup) _IntroduceReaderGroup( unsigned long hcontext, char* szGroupName );
long _IntroduceReaderGroup( unsigned long hcontext, char* szGroupName );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_ISVALIDCONTEXT
"
This function determines whether a smart card context handle is still 
valid.  After a smart card context handle has been set by 
SCardEstablishContext(), it may become not valid if the resource manager 
service has been shut down.  

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult = SCardIsValidContext( hcontext )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Invalid context: ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_ISVALIDCONTEXT;
%rename(SCardIsValidContext) _IsValidContext( unsigned long hContext );
long _IsValidContext( unsigned long hContext );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_LISTINTERFACES
"
Provides a list of interfaces supplied by a given card.  The caller 
supplies the name of a smart card previously introduced to the subsystem, 
and receives the list of interfaces supported by the card 

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult, interfaces = SCardListInterfaces( hcontext, 'Schlumberger Cryptoflex 8k v2' )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failed to list interfaces: ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_LISTINTERFACES;
%rename(SCardListInterfaces) _ListInterfaces( unsigned long hContext, char* szCard, GUIDLIST* OUTPUT );
long _ListInterfaces( unsigned long hContext, char* szCard, GUIDLIST* OUTPUT );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_LISTCARDS
"
Searches the smart card database and provides a list of named cards 
previously introduced to the system by the user.  The caller specifies an 
ATR string, a set of interface identifiers (GUIDs), or both.  If both an 
ATR string and an identifier array are supplied, the cards returned will 
match the ATR string supplied and support the interfaces specified.  

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
...
slbCryptoFlex8kv2ATR = [ 0x3B, 0x95, 0x15, 0x40, 0x00, 0x68, 0x01, 0x02, 0x00, 0x00  ]
hresult, card = SCardListCards( hcontext, slbCryptoFlex8kv2ATR, [] )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failure to locate Schlumberger Cryptoflex 8k v2 card: ' + SCardGetErrorMessage(hresult)
hresult, cards = SCardListCards( hcontext, [], [] )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failure to list cards: ' + SCardGetErrorMessage(hresult)
print 'Cards: ', cards
...
"
%enddef
%feature("docstring") DOCSTRING_LISTCARDS;
%rename (SCardListCards) _ListCards(
    unsigned long hContext,
    BYTELIST* INPUT,
    GUIDLIST* INPUT,
    STRINGLIST* OUTPUT );
long _ListCards(
    unsigned long hContext,
    BYTELIST* INPUT,
    GUIDLIST* INPUT,
    STRINGLIST* OUTPUT );

///////////////////////////////////////////////////////////////////////////////
%apply READERSTATELIST *BOTH {READERSTATELIST *prsl};
%apply STRINGLIST *INPUT {STRINGLIST *psl};
%define DOCSTRING_LOCATECARDS
"
Searches the readers listed in the rgReaderStates parameter for a card 
with an ATR string that matches one of the card names specified in 
mszCards, returning immediately with the result.  

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult, readers = SCardListReaders( hcontext, [] )
readerstates = []
cards = [ 'Schlumberger Cryptoflex 4k', 'Schlumberger Cryptoflex 8k', 'Schlumberger Cryptoflex 8k v2' ]
for i in xrange(len(readers)):
    readerstates += [ (readers[i], SCARD_STATE_UNAWARE ) ]
hresult, newstates = SCardLocateCards( hcontext, cards, readerstates )
for i in newstates:
    reader, eventstate, atr = i
    print reader,
    for b in atr:
        print '0x%.2X' % b,
    print ""
    if eventstate & SCARD_STATE_ATRMATCH:
        print 'Card found'
    if eventstate & SCARD_STATE_EMPTY:
        print 'Reader empty'
    if eventstate & SCARD_STATE_PRESENT:
        print 'Card present in reader'
...
"
%enddef
%feature("docstring") DOCSTRING_LOCATECARDS;
%rename(SCardLocateCards) _LocateCards(
    unsigned long hContext,
    STRINGLIST *INPUT,
    READERSTATELIST *prsl );
long _LocateCards(
    unsigned long hContext,
    STRINGLIST *INPUT,
    READERSTATELIST *prsl );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_REMOVEREADERFROMGROUP
"

Removes a reader from an existing reader group.  This function has no 
affect on the reader.  

Windows only, not supported by PCSC lite wrapper.

from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult = SCardRemoveReaderFromGroup( hcontext, 'SchlumbergerSema Reflex USB v.2 0', 'SCard$MyOwnGroup' )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Unable to remove reader from group: ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_REMOVEREADERFROMGROUP;
%rename(SCardRemoveReaderFromGroup) _RemoveReaderFromGroup(
  unsigned long hContext,
  char* szReaderName,
  char* szGroupName );
long _RemoveReaderFromGroup(
  unsigned long hContext,
  char* szReaderName,
  char* szGroupName );

#endif // WIN32

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_BEGINTRANSACTION
"
This function establishes a temporary exclusive access mode for doing a 
series of commands or transaction.  You might want to use this when you 
are selecting a few files and then writing a large file so you can make 
sure that another application will not change the current file.  If 
another application has a lock on this reader or this application is in 
SCARD_SHARE_EXCLUSIVE there will be no action taken.  

from smartcard.scard import *
... establish context ...
hresult, hcard, dwActiveProtocol = SCardConnect(
    hcontext, 'SchlumbergerSema Reflex USB v.2 0', SCARD_SHARE_SHARED, SCARD_PROTOCOL_T0 )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'unable to connect: ' + SCardGetErrorMessage(hresult)
hresult = SCardBeginTransaction( hcard )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'failed to begin transaction: ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_BEGINTRANSACTION;
%rename(SCardBeginTransaction) _BeginTransaction( unsigned long hCard );
long _BeginTransaction( unsigned long hCard );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_CONNECT
"
This function establishes a connection to the friendly name of the reader 
specified in szReader.  The first connection will power up and perform a 
reset on the card.  

Value of dwShareMode 	Meaning
SCARD_SHARE_SHARED 	    This application will allow others to share the reader
SCARD_SHARE_EXCLUSIVE 	This application will NOT allow others to share the reader
SCARD_SHARE_DIRECT 	    Direct control of the reader, even without a card

SCARD_SHARE_DIRECT can be used before using SCardControl() to send control 
commands to the reader even if a card is not present in the reader.  

Value of dwPreferredProtocols 	Meaning
SCARD_PROTOCOL_T0 	            Use the T=0 protocol
SCARD_PROTOCOL_T1 	            Use the T=1 protocol
SCARD_PROTOCOL_RAW 	            Use with memory type cards

from smartcard.scard import *
... establish context ...
hresult, readers = SCardListReaders( hcontext, 'NULL' )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failed to list readers:: ' + SCardGetErrorMessage(hresult)
hresult, hcard, dwActiveProtocol = SCardConnect(
    hcontext, readers[0], SCARD_SHARE_SHARED, SCARD_PROTOCOL_T0 )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'unable to connect: ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_CONNECT;
%rename(SCardConnect) _Connect(
  unsigned long hContext,
  char* szReader,
  unsigned long dwShareMode,
  unsigned long dwPreferredProtocols,
  unsigned long* OUTPUT,
  unsigned long* OUTPUT
);
long _Connect(
  unsigned long hContext,
  char* szReader,
  unsigned long dwShareMode,
  unsigned long dwPreferredProtocols,
  unsigned long* OUTPUT,
  unsigned long* OUTPUT
);

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_DISCONNECT
"
This function terminates a connection to the connection made through 
SCardConnect.  disposition can have the following values: 

Value of disposition 	Meaning
SCARD_LEAVE_CARD 	    Do nothing
SCARD_RESET_CARD 	    Reset the card (warm reset)
SCARD_UNPOWER_CARD 	    Unpower the card (cold reset)
SCARD_EJECT_CARD 	    Eject the card

from smartcard.scard import *
... establish context and connect to card ...
hresult = SCardDisconnect( hcard, SCARD_UNPOWER_CARD )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'failed to disconnect: ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_DISCONNECT;
%rename(SCardDisconnect) _Disconnect( unsigned long hCard, unsigned long dwDisposition );
long _Disconnect( unsigned long hCard, unsigned long dwDisposition );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_ENDTRANSACTION
"

This function ends a previously begun transaction.  The calling 
application must be the owner of the previously begun transaction or an 
error will occur.  disposition can have the following values: The 
disposition action is not currently used in this release.  

Value of disposition 	Meaning
SCARD_LEAVE_CARD 	    Do nothing
SCARD_RESET_CARD 	    Reset the card
SCARD_UNPOWER_CARD 	    Unpower the card
SCARD_EJECT_CARD 	    Eject the card

from smartcard.scard import *
... establish context, connect to card, begin transaction ...
hresult = SCardEndTransaction( hcard, SCARD_LEAVE_CARD )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'failed to end transaction: ' + SCardGetErrorMessage(hresult)
"
%enddef
%feature("docstring") DOCSTRING_ENDTRANSACTION;
%rename(SCardEndTransaction) _EndTransaction( unsigned long hCard, unsigned long dwDisposition );
long _EndTransaction( unsigned long hCard, unsigned long dwDisposition );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_ESTABLISHCONTEXT
"
This function creates a communication context to the PC/SC Resource 
Manager.  This must be the first function called in a PC/SC application.  

Value of dwScope 	    Meaning
SCARD_SCOPE_USER 	    Not used
SCARD_SCOPE_TERMINAL 	Not used
SCARD_SCOPE_GLOBAL 	    Not used
SCARD_SCOPE_SYSTEM 	    Services on the local machine


from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failed to establish context: ' + SCardGetErrorMessage(hresult)
"
%enddef
%feature("docstring") DOCSTRING_ESTABLISHCONTEXT;
%rename(SCardEstablishContext) _EstablishContext( unsigned long dwScope, unsigned long *OUTPUT );
long _EstablishContext( unsigned long dwScope, unsigned long *OUTPUT );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_GETATTRIB
"

This function get an attribute from the IFD Handler.

For PCSC lite, the list of possible attributes is:

    * SCARD_ATTR_ASYNC_PROTOCOL_TYPES
    * SCARD_ATTR_ATR_STRING
    * SCARD_ATTR_CHANNEL_ID
    * SCARD_ATTR_CHARACTERISTICS
    * SCARD_ATTR_CURRENT_BWT
    * SCARD_ATTR_CURRENT_CLK
    * SCARD_ATTR_CURRENT_CWT
    * SCARD_ATTR_CURRENT_D
    * SCARD_ATTR_CURRENT_EBC_ENCODING
    * SCARD_ATTR_CURRENT_F
    * SCARD_ATTR_CURRENT_IFSC
    * SCARD_ATTR_CURRENT_IFSD
    * SCARD_ATTR_CURRENT_IO_STATE
    * SCARD_ATTR_CURRENT_N
    * SCARD_ATTR_CURRENT_PROTOCOL_TYPE
    * SCARD_ATTR_CURRENT_W
    * SCARD_ATTR_DEFAULT_CLK
    * SCARD_ATTR_DEFAULT_DATA_RATE
    * SCARD_ATTR_DEVICE_FRIENDLY_NAME_A
    * SCARD_ATTR_DEVICE_FRIENDLY_NAME_W
    * SCARD_ATTR_DEVICE_IN_USE
    * SCARD_ATTR_DEVICE_SYSTEM_NAME_A
    * SCARD_ATTR_DEVICE_SYSTEM_NAME_W
    * SCARD_ATTR_DEVICE_UNIT
    * SCARD_ATTR_ESC_AUTHREQUEST
    * SCARD_ATTR_ESC_CANCEL
    * SCARD_ATTR_ESC_RESET
    * SCARD_ATTR_EXTENDED_BWT
    * SCARD_ATTR_ICC_INTERFACE_STATUS
    * SCARD_ATTR_ICC_PRESENCE
    * SCARD_ATTR_ICC_TYPE_PER_ATR
    * SCARD_ATTR_MAX_CLK
    * SCARD_ATTR_MAX_DATA_RATE
    * SCARD_ATTR_MAX_IFSD
    * SCARD_ATTR_MAXINPUT
    * SCARD_ATTR_POWER_MGMT_SUPPORT
    * SCARD_ATTR_SUPRESS_T1_IFS_REQUEST
    * SCARD_ATTR_SYNC_PROTOCOL_TYPES
    * SCARD_ATTR_USER_AUTH_INPUT_DEVICE
    * SCARD_ATTR_USER_TO_CARD_AUTH_DEVICE
    * SCARD_ATTR_VENDOR_IFD_SERIAL_NO
    * SCARD_ATTR_VENDOR_IFD_TYPE
    * SCARD_ATTR_VENDOR_IFD_VERSION
    * SCARD_ATTR_VENDOR_NAME

For Windows Resource Manager, the list of possible attributes is:

    * SCARD_ATTR_VENDOR_NAME
    * SCARD_ATTR_VENDOR_IFD_TYPE
    * SCARD_ATTR_VENDOR_IFD_VERSION
    * SCARD_ATTR_VENDOR_IFD_SERIAL_NO
    * SCARD_ATTR_CHANNEL_ID
    * SCARD_ATTR_DEFAULT_CLK
    * SCARD_ATTR_MAX_CLK
    * SCARD_ATTR_DEFAULT_DATA_RATE
    * SCARD_ATTR_MAX_DATA_RATE
    * SCARD_ATTR_MAX_IFSD
    * SCARD_ATTR_POWER_MGMT_SUPPORT
    * SCARD_ATTR_USER_TO_CARD_AUTH_DEVICE
    * SCARD_ATTR_USER_AUTH_INPUT_DEVICE
    * SCARD_ATTR_CHARACTERISTICS
    * SCARD_ATTR_CURRENT_PROTOCOL_TYPE
    * SCARD_ATTR_CURRENT_CLK
    * SCARD_ATTR_CURRENT_F
    * SCARD_ATTR_CURRENT_D
    * SCARD_ATTR_CURRENT_N
    * SCARD_ATTR_CURRENT_W
    * SCARD_ATTR_CURRENT_IFSC
    * SCARD_ATTR_CURRENT_IFSD
    * SCARD_ATTR_CURRENT_BWT
    * SCARD_ATTR_CURRENT_CWT
    * SCARD_ATTR_CURRENT_EBC_ENCODING
    * SCARD_ATTR_EXTENDED_BWT
    * SCARD_ATTR_ICC_PRESENCE
    * SCARD_ATTR_ICC_INTERFACE_STATUS
    * SCARD_ATTR_CURRENT_IO_STATE
    * SCARD_ATTR_ATR_STRING
    * SCARD_ATTR_ICC_TYPE_PER_ATR
    * SCARD_ATTR_ESC_RESET
    * SCARD_ATTR_ESC_CANCEL
    * SCARD_ATTR_ESC_AUTHREQUEST
    * SCARD_ATTR_MAXINPUT
    * SCARD_ATTR_DEVICE_UNIT
    * SCARD_ATTR_DEVICE_IN_USE
    * SCARD_ATTR_DEVICE_FRIENDLY_NAME_A
    * SCARD_ATTR_DEVICE_SYSTEM_NAME_A
    * SCARD_ATTR_DEVICE_FRIENDLY_NAME_W
    * SCARD_ATTR_DEVICE_SYSTEM_NAME_W
    * SCARD_ATTR_SUPRESS_T1_IFS_REQUEST
     
Not all the dwAttrId values listed above may be implemented in the IFD 
Handler you are using.  And some dwAttrId values not listed here may be 
implemented.


from smartcard.scard import *
... establish context and connect to card ...
hresult, attrib = SCardGetAttrib( hcard, SCARD_ATTR_ATR_STRING )
if hresult==SCARD_S_SUCCESS:
    for j in attrib:
         print '0x%.2X' % attrib,
...
"
%enddef
%feature("docstring") DOCSTRING_GETATTRIB;
%rename(SCardGetAttrib) _GetAttrib( unsigned long hcard, unsigned long dwAttrId, BYTELIST* OUTPUT );
long _GetAttrib( unsigned long hcard, unsigned long dwAttrId, BYTELIST* OUTPUT );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_GETSTATUSCHANGE
"

This function receives a structure or list of tuples containing reader 
states. A READERSTATE hast three fields ( readername, state, atr ).
It then blocks for a change in state to occur on any of the OR'd 
values contained in the current state for a maximum blocking time of 
dwTimeout or forever if INFINITE is used.  The new event state will be 
contained in state.  A status change might be a card insertion or 
removal event, a change in ATR, etc.  

Value of state              Meaning
SCARD_STATE_UNAWARE 	    The application is unaware of the current state, and would like to know. The use of this value results in an immediate return from state transition monitoring services. This is represented by all bits set to zero
SCARD_STATE_IGNORE 	        This reader should be ignored
SCARD_STATE_CHANGED 	    There is a difference between the state believed by the application, and the state known by the resource manager. When this bit is set, the application may assume a significant state change has occurred on this reader
SCARD_STATE_UNKNOWN 	    The given reader name is not recognized by the resource manager. If this bit is set, then SCARD_STATE_CHANGED and SCARD_STATE_IGNORE will also be set
SCARD_STATE_UNAVAILABLE 	The actual state of this reader is not available. If this bit is set, then all the following bits are clear
SCARD_STATE_EMPTY 	        There is no card in the reader. If this bit is set, all the following bits will be clear
SCARD_STATE_PRESENT 	    There is a card in the reader
SCARD_STATE_ATRMATCH 	    There is a card in the reader with an ATR matching one of the target cards. If this bit is set, SCARD_STATE_PRESENT will also be set. This bit is only returned on the SCardLocateCards function
SCARD_STATE_EXCLUSIVE 	    The card in the reader is allocated for exclusive use by another application. If this bit is set, SCARD_STATE_PRESENT will also be set
SCARD_STATE_INUSE 	        The card in the reader is in use by one or more other applications, but may be connected to in shared mode. If this bit is set, SCARD_STATE_PRESENT will also be set
SCARD_STATE_MUTE 	        There is an unresponsive card in the reader


from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult, readers = SCardListReaders( hcontext, [] )
readerstates = []
cards = [ 'Schlumberger Cryptoflex 4k', 'Schlumberger Cryptoflex 8k', 'Schlumberger Cryptoflex 8k v2' ]
for i in xrange(len(readers)):
    readerstates += [ (readers[i], SCARD_STATE_UNAWARE ) ]
hresult, newstates = SCardLocateCards( hcontext, cards, readerstates )
print '----- Please insert or remove a card ------------'
hresult, newstates = SCardGetStatusChange( hcontext, INFINITE, newstates )
for i in newstates
     reader, eventstate, atr = i
    if eventstate & SCARD_STATE_ATRMATCH:
        print '\tCard found'
    if eventstate & SCARD_STATE_EMPTY:
        print '\tReader empty'
"
%enddef
%feature("docstring") DOCSTRING_GETSTATUSCHANGE;
%rename(SCardGetStatusChange) _GetStatusChange(
    unsigned long hContext,
    unsigned long dwTimeout,
    READERSTATELIST *BOTH);
long _GetStatusChange(
    unsigned long hContext,
    unsigned long dwTimeout,
    READERSTATELIST *BOTH);

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_LISTREADERS
"
This function returns a list of currently available readers on the system.
A list of group can be provided in input to list readers in a given group only.

from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult, readers = SCardListReaders( hcontext, [] )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failed to list readers: ' + SCardGetErrorMessage(hresult)
print 'PCSC Readers: ', readers
hresult, readers = SCardListReaders( hcontext, ['SCard$T1ProtocolReaders', 'SCard$MyOwnGroup']
...
"
%enddef
%feature("docstring") DOCSTRING_LISTREADERS;
%rename(SCardListReaders) _ListReaders(
    unsigned long hContext,
    STRINGLIST *INPUT,
    STRINGLIST *OUTPUT );
long _ListReaders(
    unsigned long hContext,
    STRINGLIST *INPUT,
    STRINGLIST *OUTPUT );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_LISTREADERGROUPS
"
This function returns a list of currently available reader groups on the system. 

from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult, readerGroups = SCardListReaderGroups( hcontext )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Unable to list reader groups: ' + SCardGetErrorMessage(hresult)
print 'PCSC Reader groups: ', readerGroups
"
%enddef
%feature("docstring") DOCSTRING_LISTREADERGROUPS;
%rename(SCardListReaderGroups) _ListReaderGroups( unsigned long hContext, STRINGLIST *OUTPUT );
long _ListReaderGroups( unsigned long hContext, STRINGLIST *OUTPUT );

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_RECONNECT
"

This function reestablishes a connection to a reader that was previously 
connected to using SCardConnect().  In a multi application environment it 
is possible for an application to reset the card in shared mode.  When 
this occurs any other application trying to access certain commands will 
be returned the value SCARD_W_RESET_CARD.  When this occurs 
SCardReconnect() must be called in order to acknowledge that the card was 
reset and allow it to change it's state accordingly.  

Value of dwShareMode 	Meaning
SCARD_SHARE_SHARED 	    This application will allow others to share the reader
SCARD_SHARE_EXCLUSIVE 	This application will NOT allow others to share the reader

Value of dwPreferredProtocols 	Meaning
SCARD_PROTOCOL_T0 	            Use the T=0 protocol
SCARD_PROTOCOL_T1 	            Use the T=1 protocol
SCARD_PROTOCOL_RAW 	            Use with memory type cards

dwPreferredProtocols is a bit mask of acceptable protocols for the connection. You can use (SCARD_PROTOCOL_T0 | SCARD_PROTOCOL_T1) if you do not have a preferred protocol.

Value of dwInitialization 	Meaning
SCARD_LEAVE_CARD 	        Do nothing
SCARD_RESET_CARD 	        Reset the card (warm reset)
SCARD_UNPOWER_CARD 	        Unpower the card (cold reset)
SCARD_EJECT_CARD 	        Eject the card


from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult, hcard, dwActiveProtocol = SCardConnect(
    hcontext, 'SchlumbergerSema Reflex USB v.2 0', SCARD_SHARE_SHARED, SCARD_PROTOCOL_T0 )
hresult, activeProtocol = SCardReconnect( hcard, SCARD_SHARE_EXCLUSIVE,
    SCARD_PROTOCOL_T0, SCARD_RESET_CARD )
...
"
%enddef
%feature("docstring") DOCSTRING_RECONNECT;
%rename(SCardReconnect) _Reconnect(
  unsigned long hCard,
  unsigned long dwShareMode,
  unsigned long dwPreferredProtocols,
  unsigned long dwInitialization,
  unsigned long* pdwActiveProtocol
);
long _Reconnect(
  unsigned long hCard,
  unsigned long dwShareMode,
  unsigned long dwPreferredProtocols,
  unsigned long dwInitialization,
  unsigned long* pdwActiveProtocol
);

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_RELEASECONTEXT
"
"
%enddef
%feature("docstring") DOCSTRING_RELEASECONTEXT;
%rename(SCardReleaseContext) _ReleaseContext( unsigned long hContext );
long _ReleaseContext( unsigned long hContext );

///////////////////////////////////////////////////////////////////////////////
%typemap(doc, name="readername", type="string") (STRINGLIST*  OUTPUT) "readername: in output, the friendly reader name";
%typemap(doc, name="atr", type="bytelist") (BYTELIST* OUTPUT) "atr: in output, the card atr";
%define DOCSTRING_STATUS
"
This function returns the current status of the reader connected to by 
hCard.  The reader friendly name is returned, as well as the state, 
protocol and ATR.  The state is a DWORD possibly OR'd with the following 
values: 

Value of pdwState 	Meaning
SCARD_ABSENT 	    There is no card in the reader
SCARD_PRESENT 	    There is a card in the reader, but it has not been moved into position for use
SCARD_SWALLOWED 	There is a card in the reader in position for use. The card is not powered
SCARD_POWERED 	    Power is being provided to the card, but the reader driver is unaware of the mode of the card
SCARD_NEGOTIABLE 	The card has been reset and is awaiting PTS negotiation
SCARD_SPECIFIC 	    The card has been reset and specific communication protocols have been established

Value of pdwProtocol 	Meaning
SCARD_PROTOCOL_T0 	    Use the T=0 protocol
SCARD_PROTOCOL_T1 	    Use the T=1 protocol


from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult, hcard, dwActiveProtocol = SCardConnect(
         hcontext, 'SchlumbergerSema Reflex USB v.2 0', SCARD_SHARE_SHARED, SCARD_PROTOCOL_T0 )
hresult, reader, state, protocol, atr = SCardStatus( hcard )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'failed to get status: ' + SCardGetErrorMessage(hresult)
print 'Reader: ', reader
print 'State: ', state
print 'Protocol: ', protocol
print 'ATR: ',
for i in xrange(len(atr)):
    print '0x%.2X' % i,
print ""
...
"
%enddef
%feature("docstring") DOCSTRING_STATUS;
%rename(SCardStatus) _Status(
  unsigned long hCard,
  STRINGLIST*  OUTPUT,
  unsigned long* OUTPUT,
  unsigned long* OUTPUT,
  BYTELIST* OUTPUT
);
long _Status(
  unsigned long hCard,
  STRINGLIST*  OUTPUT,
  unsigned long* OUTPUT,
  unsigned long* OUTPUT,
  BYTELIST* OUTPUT
);

///////////////////////////////////////////////////////////////////////////////
%typemap(doc, name="ApduCommand", type="list") (BYTELIST* INPUT) "ApduCommand: bytelist";
%typemap(doc, name="ApduResponse", type="list") (BYTELIST* OUTPUT) "ApduResponse: bytelist";
%define DOCSTRING_TRANSMIT
"
This function sends an APDU to the smart card contained in the reader connected to by SCardConnect(). 
It returns a result and the card APDU response.

Value of pioSendPci 	Meaning
SCARD_PCI_T0 	        Pre-defined T=0 PCI structure
SCARD_PCI_T1 	        Pre-defined T=1 PCI structure


from smartcard.scard import *
hresult, hcontext = SCardEstablishContext( SCARD_SCOPE_USER )
hresult, hcard, dwActiveProtocol = SCardConnect(
     hcontext, 'SchlumbergerSema Reflex USB v.2 0', SCARD_SHARE_SHARED, SCARD_PROTOCOL_T0 )
SELECT = [0xA0, 0xA4, 0x00, 0x00, 0x02]
DF_TELECOM = [0x7F, 0x10]
hresult, response = SCardTransmit( hcard, SCARD_PCI_T0, SELECT + DF_TELECOM )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failed to transmit: ' + SCardGetErrorMessage(hresult)
"
%enddef
%feature("docstring") DOCSTRING_TRANSMIT;
%rename(SCardTransmit) _Transmit(
  unsigned long hCard,
  unsigned long pioSendPci,
  BYTELIST* INPUT,
  BYTELIST* OUTPUT
);
long _Transmit(
  unsigned long hCard,
  unsigned long pioSendPci,
  BYTELIST* INPUT,
  BYTELIST* OUTPUT
);

///////////////////////////////////////////////////////////////////////////////
%define DOCSTRING_GETERRORMESSAGE
"
This function return a human readable text for the given PC/SC error code.

from smartcard.scard import *
...
hresult, response = SCardTransmit( hcard, SCARD_PCI_T0, SELECT + DF_TELECOM )
if hresult!=SCARD_S_SUCCESS:
    raise error, 'Failed to transmit: ' + SCardGetErrorMessage(hresult)
...
"
%enddef
%feature("docstring") DOCSTRING_GETERRORMESSAGE;
%rename(SCardGetErrorMessage) _GetErrorMessage( long lErrCode );
ERRORSTRING* _GetErrorMessage( long lErrCode );


%inline
%{
%}

%{
    PyObject *PyExc_SCardError=NULL;
%}


//----------------------------------------------------------------------
// This code gets added to the module initialization function
//----------------------------------------------------------------------
%init
%{
    PyExc_SCardError = PyErr_NewException("scard.error", NULL, NULL);
    if (PyExc_SCardError != NULL)
            PyDict_SetItemString(d, "error", PyExc_SCardError);
%}

//----------------------------------------------------------------------
// This code is added to the scard.py python module
//----------------------------------------------------------------------
%pythoncode %{
    error = _scard.error
%}

%include PcscDefs.i

#ifdef PCSCLITEyy
%pythoncode %{

def SCardListCards( hContext, atr, guidlist ):
    return ( SCARD_S_SUCCESS, [] )

def SCardLocateCards( hContext, cardnames, readerstates ):
    newreaderstates=[]
    for state in readerstates:
        newreaderstates.append( (state[0], state[1], [] ) )

    return ( SCARD_S_SUCCESS, newreaderstates )
%}
#endif

#ifdef PCSCLITE
%constant char* resourceManager = "pcsclite" ;
#endif // PCSCLITE
#ifdef WIN32
%constant char* resourceManager = "winscard" ;
#endif // WIN32

