#
# $Id: Makefile.PL,v 28.1 2007/02/08 19:41:39 biersma Exp $
#
# (c) 1999-2007 Morgan Stanley Dean Witter and Co.
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

