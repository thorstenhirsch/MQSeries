#
# $Id: Makefile.PL,v 12.1 2000/02/18 03:18:12 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

use ExtUtils::MakeMaker;

require "../util/parse_config";
require "../util/parse_headers";
require "../util/fake_mm";

if ( $::has_mqrfh ) {
    WriteMakefile(
		  NAME	   	=> 'MQSeries::Message::RulesFormat',
		  VERSION_FROM 	=> 'RulesFormat.pm',
		  INC		=> qq{-I"$include"},
		  (
		   $Config{archname} =~ /-object\b/i ?
		   (
		    CAPI	=> 'TRUE',
		   ) : ()
		  )
		 );
}
else {
    warn("Your MQSeries installation doesn't support the MQRFH structure\n" .
	 "Disabling the MQSeries::Message::RulesFormat module\n");
    myWriteEmptyMakefile();
}
