#
# $Id: 60-logs.t,v 16.2 2001/01/05 21:46:50 wpm Exp $
#
# (c) 2000-2001 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

BEGIN {
    $| = 1;
    print "1..1\n";
}

END { print "not ok 1\n" unless $loaded; }

use MQSeries::ErrorLog::Tail 1.13;
use MQSeries::FDC::Tail 1.13;
$loaded = 1;
print "ok 1\n";

#
# For now, all this test really buys us is a sanity check that there
# are no syntax errors in any of the log-parsing related files.
#
