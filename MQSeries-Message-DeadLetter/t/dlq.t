#
# $Id: dlq.t,v 33.2 2009/07/10 17:04:41 biersma Exp $
#
# (c) 1999-2009 Morgan Stanley & Co. Incorporated
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
use MQSeries 1.30;
use MQSeries::Message::DeadLetter 1.30 qw( MQDecodeDeadLetter MQEncodeDeadLetter );
$loaded = 1;
print "ok 1\n";

