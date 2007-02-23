#
# $Id: Makefile.PL,v 28.1 2007/02/08 19:41:58 biersma Exp $
#
# (c) 1999-2007 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

use ExtUtils::MakeMaker;

require "../util/parse_config";
require "../util/parse_headers";

#
# This ain't ready yet...
#
if ( 0 ) {

    WriteMakefile(
		  NAME	   	=> 'MQSeries::OAM',
		  VERSION_FROM	=> 'OAM.pm',
		  INC		=> qq{-I"$include"},
		  (
		   $Config{archname} =~ /-object\b/i ?
		   (
		    CAPI 		=> 'TRUE',
		   ) : ()
		  )
		 );

} else {
    myWriteEmptyMakefile();
}

