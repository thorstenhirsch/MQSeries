#
# $Id: Makefile.PL,v 20.1 2002/03/18 20:33:19 biersma Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
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

