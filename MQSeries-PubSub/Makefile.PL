#
# $Id: Makefile.PL,v 16.1 2001/01/05 21:43:25 wpm Exp $
#
# (c) 1999-2001 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

use ExtUtils::MakeMaker;

require "../util/parse_config";
require "../util/parse_headers";
require "../util/fake_mm";

if ( $::has_mqrfh ) {
    WriteMakefile(
		  NAME	   	=> 'MQSeries::PubSub',
		  VERSION_FROM 	=> 'PubSub/Broker.pm',
		  (
		   $^O eq 'os390' ?
		   (
		    MAN3PODS	=> {},
		   ) : ()
		  ),
		 );
}
else {
    warn("Your MQSeries installation doesn't support the MQRFH structure\n" .
	 "Disabling the MQSeries::PubSub::* modules\n");
    myWriteEmptyMakefile();
}

