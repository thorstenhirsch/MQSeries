#
# $Id: oam.t,v 24.1 2003/05/19 21:32:10 biersma Exp $
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

#
# The number of tests has to be updated experimentally if the tests
# are extended.
#
BEGIN {
    print "1..1\n";
}

#
# We need this to pick up the PERL_DL_NONLAZY definition,
# conditionally.
#
BEGIN {
    require "../util/parse_config";
}

END { print "not ok 1\n" unless $loaded; }
use MQSeries::OAM 1.21;
$loaded = 1;
print "ok 1\n";

