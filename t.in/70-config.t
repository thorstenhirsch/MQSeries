#
# $Id: 70-config.t,v 17.3 2001/03/30 21:47:22 wpm Exp $
#
# (c) 2000-2001 Morgan Stanley Dean Witter and Co.
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

use __APITYPE__::MQSeries 1.14;
use MQSeries::Config::Machine 1.14;
use MQSeries::Config::QMgr 1.14;
$loaded = 1;
print "ok 1\n";

#
# For now, all this test really buys us is a sanity check that there
# are no syntax errors in any of the configuration-parsing related files.
#
