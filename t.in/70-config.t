#
# $Id: 70-config.t,v 16.2 2001/01/05 21:46:51 wpm Exp $
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

use MQSeries::Config::Authority 1.13;
use MQSeries::Config::Machine 1.13;
use MQSeries::Config::QMgr 1.13;
$loaded = 1;
print "ok 1\n";

#
# For now, all this test really buys us is a sanity check that there
# are no syntax errors in any of the configuration-parsing related files.
#
