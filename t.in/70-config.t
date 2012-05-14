#
# $Id: 70-config.t,v 33.7 2011/01/03 15:05:03 anbrown Exp $
#
# (c) 2000-2011 Morgan Stanley & Co. Incorporated
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

use __APITYPE__::MQSeries 1.33;
use MQSeries::Config::Machine 1.33;
use MQSeries::Config::QMgr 1.33;
$loaded = 1;
print "ok 1\n";

#
# For now, all this test really buys us is a sanity check that there
# are no syntax errors in any of the configuration-parsing related files.
#
