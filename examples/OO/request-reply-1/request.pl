#!/ms/dist/perl5/bin/perl5.005-thread
#
# $Id: request.pl,v 23.1 2003/04/10 19:10:26 biersma Exp $
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#
# This code sends requests to a queue, and listens for responses on a
# fixed, shared reply queue.
#

$::expiry = 10000;
$::qmgrname = 'SAT1';
$::requestqname = 'PERL.EXAMPLES.RR1.REQUEST';
$::replyqname = 'PERL.EXAMPLES.RR1.REPLY';

use strict;

use MQSeries;
use MQSeries::QueueManager;
use MQSeries::Queue;
use MQSeries::Message;

#
# Step one: connect to the queuemanager.
#
$::qmgr = MQSeries::QueueManager->new( QueueManager => $::qmgrname ) ||
  die "Unable to conne to queue manager $::qmgrname\n";

#
# Step two: open both the request and reply queues
#
$::requestq = MQSeries::Queue->new
  (
   QueueManager		=> $::qmgr,
   Queue		=> $::requestqname,
   Mode			=> 'output',
  ) || die "Unable to open $::requestqname\n";

$::replyq = MQSeries::Queue->new
  (
   QueueManager		=> $::qmgr,
   Queue		=> $::replyqname,
   Mode			=> 'input',
  ) || die "Unable to open $::replyqname\n";

#
# Now, loop in STDIN, and put each individual line of input into a
# message to be sent as a request.  Stop when we get an empty line.
#
print "Please enter your 'requests', one per line.\n";

while ( <> ) {

    chomp;

    last unless $_;

    my $request = MQSeries::Message->new
      (
       MsgDesc		=>
       {
	Format		=> MQFMT_STRING,
	Expiry		=> $::expiry,
       },
       Data		=> $_,
      );

    $::requestq->Put( Message => $request ) ||
      die "Unable to put message to $::requestqname\n";

    my $reply = MQSeries::Message->new
      (
       MsgDesc		=>
       {
	CorrelId	=> $request->MsgDesc('MsgId'),
       },
      );

    my $result = $::replyq->Get
      (
       Message 		=> $reply,
       Wait		=> $::expiry,
      );

    if ( $result > 0 ) {
	# > 0 is success
	print "Response => " . $reply->Data() . "\n";
    }
    elsif ( $result < 0 ) {
	# < 0 (really -1) is for MQRC_NO_MSG_AVAILABLE
	die "Timed out while waiting for a response!!\n";
    }
    else {
	# 0 is for any other error
	die "Error occured while waiting for response.\n";
    }

}
