#
# $Id: Makefile.PL,v 15.1 2000/09/14 20:21:07 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

use ExtUtils::MakeMaker;

require "../util/parse_config";
require "../util/parse_headers";
require "../util/fake_mm";

if ( $::has_mqmd2 ) {

    WriteMakefile(
		  NAME	   	=> 'MQSeries::Message::DeadLetter',
		  VERSION_FROM 	=> 'DeadLetter.pm',
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
		    CAPI	=> 'TRUE',
		   ) : ()
		  )
		 );

} else {
    warn("Your MQSeries installation doesn't support the MQMD version 2 structure\n" .
	 "Disabling the MQSeries::Message::DeadLetter module\n");
    myWriteEmptyMakefile();
}

