#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

static char rcsid[] = "$Id: OAM.xs,v 16.1 2001/01/05 21:43:23 wpm Exp $";

/*
  (c) 1999-2001 Morgan Stanley Dean Witter and Co.
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

#ifndef __MVS__
#include "cmqzc.h"
#else
#include "../inc/cmqzc.h"
#endif /* ! __MVS__ */

/*#define DEBUGME*/

#ifdef DEBUGME
#define TRACEME(x)	do { PerlIO_stdoutf x; PerlIO_stdoutf("\n"); } while (0)
#else
#define TRACEME(x)
#endif

MODULE = MQSeries::OAM			PACKAGE = MQSeries::OAM

void
zfu_as_CheckObjectAuthority(QMgrName,
			    Entity,EntityType,
			    ObjectName,ObjectType,
			    Authority,
			    ComponentData,
			    Continuation,
			    CompCode,Reason)


	PPCODE:
	{
	}

void
zfu_as_CopyAllObjectAuthority()

	PPCODE:
	{
	}

void
zfu_as_DeleteObjectAuthority()

	PPCODE:
	{
	}

void
zfu_as_GetObjectAuthority()

	PPCODE:
	{
	}

void
zfu_as_GetXplicitAuthority()

	PPCODE:
	{
	}

void
zfu_as_SetObjectAuthority()

	PPCODE:
	{
	}

