#
# $Id: 60-logs.t,v 15.1 2000/09/28 09:25:01 biersma Exp $
#
# (c) 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

BEGIN {
    $| = 1;
    print "1..1\n";
}

END { print "not ok 1\n" unless $loaded; }

use MQSeries::ErrorLog::Tail 1.12;
use MQSeries::FDC::Tail 1.12;
$loaded = 1;
print "ok 1\n";

#
# For now, all this test really buys us is a sanity check that there
# are no syntax errors in any of the log-parsing related files.
#
