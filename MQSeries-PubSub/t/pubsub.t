#
# $Id: pubsub.t,v 12.1 2000/02/03 19:45:16 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

BEGIN {
    require "../util/parse_config";
    require "../util/parse_headers";
}

BEGIN { 
    $| = 1; 
    if ( $::has_mqrfh ) {
	print "1..1\n";
    }
    else {
	print "1..0\n";
	exit 0;
    }
}

END {print "not ok 1\n" unless $loaded;}
use MQSeries::PubSub::Broker 		1.09;
use MQSeries::PubSub::Stream 		1.09;
use MQSeries::PubSub::Message 		1.09;
use MQSeries::PubSub::AdminMessage 	1.09;
$loaded = 1;
print "ok 1\n";

#
# For now, all this test really buys us is a sanity check that there
# are no syntax errors in any of the PubSub related files.
#
# A real test suite for the PubSub API will require a lot of work.
# 
