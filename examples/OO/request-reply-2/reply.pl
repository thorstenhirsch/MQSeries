#!/ms/dist/perl5/bin/perl5.005-thread
#
# $Id: reply.pl,v 20.1 2002/03/18 20:34:34 biersma Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

$::pollrate = '10000';
$::qmgrname = 'SAT1';
$::requestqname = 'PERL.EXAMPLES.RR1.REQUEST';

use strict;

use MQSeries;
use MQSeries::QueueManager;
use MQSeries::Queue;
use MQSeries::Message;

#
# Step one: connect to the queuemanager.
#
$::qmgr = MQSeries::QueueManager->new( QueueManager => $::qmgrname ) ||
  die "Unable to connect to queue manager $::qmgrname\n";

#
# Step two: open both the request and reply queues
#
$::requestq = MQSeries::Queue->new
  (
   QueueManager		=> $::qmgr,
   Queue		=> $::requestqname,
   Mode			=> 'input',
  ) || die "Unable to open $::requestqname\n";

#
# Now loop on incoming messages in the request queue.
#
while ( 1 ) {

    my $request = MQSeries::Message->new();

    $::requestq->Get
      (
       Message 	=> $request,
       Wait	=> $::pollrate,
      ) || die "Error occured while waiting for requests\n";

    if ( $::requestq->Reason() == MQRC_NO_MSG_AVAILABLE ) {
	print "Timed out waiting for requests.  Retrying...\n";
	next;
    } 

    print "Request: " . $request->Data() . "\n";

    my $reply = MQSeries::Message->new
      (
       MsgDesc		=>
       {
	CorrelId	=> $request->MsgDesc('MsgId'),
	Expiry		=> $request->MsgDesc('Expiry'),
       },
       Data		=> qq(You said: ") . $request->Data() . qq("),
      );

    $::qmgr->Put1
      (
       
       Message 		=> $reply,
      ) || die "Unable to put reply message\n";

}
