#
# (c) 1999-2012 Morgan Stanley & Co. Incorporated
# See ..../src/LICENSE for terms of distribution.
#

#
# The 13 has to be updated experimentally if the tests are extended.
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
use MQSeries 1.35;
use MQSeries::Message::DeadLetter 1.35 qw( MQDecodeDeadLetter MQEncodeDeadLetter );
$loaded = 1;
print "ok 1\n";

