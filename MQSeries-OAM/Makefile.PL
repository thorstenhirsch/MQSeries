#
# $Id: Makefile.PL,v 27.1 2007/01/11 20:19:59 molinam Exp $
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
		   $^O eq 'os390' ?
		   (
		    MAN3PODS	=> {},
		   ) : ()
		  ),
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

