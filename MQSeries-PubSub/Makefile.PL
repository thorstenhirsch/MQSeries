#
# $Id: Makefile.PL,v 14.1 2000/08/15 20:51:14 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
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
		 );
}
else {
    warn("Your MQSeries installation doesn't support the MQRFH structure\n" .
	 "Disabling the MQSeries::PubSub::* modules\n");
    myWriteEmptyMakefile();
}

