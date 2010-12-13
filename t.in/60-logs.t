#
# $Id: 60-logs.t,v 33.5 2010/04/01 16:25:06 anbrown Exp $
#
# (c) 2000-2010 Morgan Stanley & Co. Incorporated
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

use __APITYPE__::MQSeries 1.32;
use MQSeries::ErrorLog::Tail 1.32;
use MQSeries::FDC::Tail 1.32;
$loaded = 1;
print "ok 1\n";

#
# For now, all this test really buys us is a sanity check that there
# are no syntax errors in any of the log-parsing related files.
#
