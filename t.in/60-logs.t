#
# $Id: 60-logs.t,v 32.1 2009/05/22 15:28:16 biersma Exp $
#
# (c) 2000-2007 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

BEGIN {
    require "../util/parse_config";
}

BEGIN {
    $| = 1;
    print "1..1\n";
}

END { print "not ok 1\n" unless $loaded; }

use __APITYPE__::MQSeries 1.29;
use MQSeries::ErrorLog::Tail 1.29;
use MQSeries::FDC::Tail 1.29;
$loaded = 1;
print "ok 1\n";

#
# For now, all this test really buys us is a sanity check that there
# are no syntax errors in any of the log-parsing related files.
#
