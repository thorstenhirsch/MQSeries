#
# $Id: 50oo-command.t,v 9.1 1999/11/02 23:40:54 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

BEGIN {
    require "../util/parse_config";
}

BEGIN { 
    $| = 1; 
    if ( "__APITYPE__" eq "MQServer" && ! -d q{/var/mqm/qmgrs/@SYSTEM} ) {
	print "1..0\n";
	exit 0;
    }
    else {
	print "1..1\n"; 
    }
}

END {print "not ok 1\n" unless $loaded;}
use __APITYPE__::MQSeries;
use MQSeries::Command;
$loaded = 1;
print "ok 1\n";

#
# For now, all this test really buys us is a sanity check that there
# are no syntax errors in any of the Command related files.
#
# A real test suite for the Command API will require a lot of work.
# 
