#
# $Id: oam.t,v 21.1 2002/03/27 15:32:09 wpm Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
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
use MQSeries::OAM 1.18;
$loaded = 1;
print "ok 1\n";

