#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

static char rcsid[] = "$Id: RulesFormat.xs,v 20.3 2002/03/19 21:49:45 wpm Exp $";

/*
  (c) 1999-2002 Morgan Stanley Dean Witter and Co.
  See ..../src/LICENSE for terms of distribution.
 */

/*
  Copied from DevelPPPort-1.0003/ppport.h
 */
#ifndef PERL_PATCHLEVEL
#       ifndef __PATCHLEVEL_H_INCLUDED__
#               include "patchlevel.h"
#       endif
#endif
#ifndef PATCHLEVEL
#   define PATCHLEVEL PERL_VERSION
#endif
#ifndef PERL_PATCHLEVEL
#       define PERL_PATCHLEVEL PATCHLEVEL
#endif
#ifndef PERL_SUBVERSION
#       define PERL_SUBVERSION SUBVERSION
#endif
 
#ifndef ERRSV
#       define ERRSV perl_get_sv("@",FALSE)
#endif
 
#if (PERL_PATCHLEVEL < 4) || ((PERL_PATCHLEVEL == 4) && (PERL_SUBVERSION <= 4))
#       define PL_sv_undef      sv_undef
#       define PL_sv_yes        sv_yes
#       define PL_sv_no         sv_no
#       define PL_na            na
#       define PL_stdingv       stdingv
#       define PL_hints         hints
#       define PL_curcop        curcop
#       define PL_curstash      curstash
#       define PL_copline       copline
#endif
 
#if (PERL_PATCHLEVEL < 5)
#  ifdef WIN32
#       define dTHR extern int Perl___notused
#  else
#       define dTHR extern int errno
#  endif
#endif
 
#ifndef boolSV
#       define boolSV(b) ((b) ? &PL_sv_yes : &PL_sv_no)
#endif

#include "cmqc.h"

MODULE = MQSeries::Message::RulesFormat		PACKAGE = MQSeries::Message::RulesFormat



void
MQDecodeRulesFormat(pBuffer,BufferLength)
	PMQCHAR pBuffer;
	MQLONG  BufferLength;

	PPCODE:
	{
	  
	  PMQCHAR pTemp = pBuffer;

	  HV *HeaderHV;
	  SV *OptionsSV, *DataSV;

	  MQRFH Header;
	  
	  if ( BufferLength < sizeof(MQRFH) ) {
	    warn("MQDecodeRulesFormat: BufferLength is smaller than the MQRFH.\n");
	    XSRETURN_EMPTY;
	  }

	  Header = *(MQRFH *)pTemp;
	  pTemp += MQRFH_STRUC_LENGTH_FIXED;
	  
	  HeaderHV = newHV();
	  
	  hv_store(HeaderHV,"StrucId",7,(newSVpv(Header.StrucId,4)),0);
	  hv_store(HeaderHV,"Format",6,(newSVpv(Header.Format,8)),0);
	  hv_store(HeaderHV,"Version",7,(newSViv(Header.Version)),0);
	  hv_store(HeaderHV,"Encoding",8,(newSViv(Header.Encoding)),0);
	  hv_store(HeaderHV,"CodedCharSetId",14,(newSViv(Header.CodedCharSetId)),0);
	  hv_store(HeaderHV,"Flags",5,(newSViv(Header.Flags)),0);
	  hv_store(HeaderHV,"StrucLength",11,(newSViv(Header.StrucLength)),0);

	  XPUSHs(sv_2mortal(newRV_noinc((SV*)HeaderHV)));

	  if ( Header.StrucLength == MQRFH_STRUC_LENGTH_FIXED )
	    OptionsSV = newSVpv("",0);
	  else
	    OptionsSV = newSVpvn(pTemp,Header.StrucLength - MQRFH_STRUC_LENGTH_FIXED);
	  
	  XPUSHs(sv_2mortal(OptionsSV));
	  
	  pTemp += Header.StrucLength - MQRFH_STRUC_LENGTH_FIXED;
	  
	  if ( BufferLength == Header.StrucLength )
	    DataSV = newSVpv("",0);
	  else
	    DataSV = newSVpvn(pTemp,BufferLength - Header.StrucLength);
	  
	  XPUSHs(sv_2mortal(DataSV));

	}



void
MQEncodeRulesFormat(Header,pOptions,OptionsLength,pData,DataLength)
     	MQRFH   Header;
	PMQCHAR pOptions;
	MQLONG	OptionsLength;
	PMQCHAR pData;
	MQLONG	DataLength;
	
	PPCODE:
	{
	  
	  SV *Result;
	  
	  Header.StrucLength = MQRFH_STRUC_LENGTH_FIXED + OptionsLength;
	  
	  Result = newSVpv((char *)&Header,MQRFH_STRUC_LENGTH_FIXED);
	  sv_catpvn(Result,(char *)pOptions,OptionsLength);
	  sv_catpvn(Result,(char *)pData,DataLength);

	  XPUSHs(sv_2mortal(Result));

	}

