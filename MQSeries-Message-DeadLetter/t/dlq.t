#
# $Id: dlq.t,v 21.1 2002/03/27 15:32:02 wpm Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
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
use MQSeries 1.18;
use MQSeries::Message::DeadLetter 1.18 qw( MQDecodeDeadLetter MQEncodeDeadLetter );
$loaded = 1;
print "ok 1\n";

