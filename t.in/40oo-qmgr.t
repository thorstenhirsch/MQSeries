#
# $Id: 40oo-qmgr.t,v 14.2 2000/08/15 20:52:35 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

BEGIN {
    require "../util/parse_config";
}

BEGIN {
    $| = 1;
    if ( "__APITYPE__" eq "MQServer" && ! -d $systemdir ) {
	print "1..0\n";
	exit 0;
    } else {
	print "1..9\n";
    }
}

END {print "not ok 1\n" unless $loaded;}
use __APITYPE__::MQSeries 1.11;
use MQSeries::QueueManager 1.11;
$loaded = 1;
print "ok 1\n";

#
# These values will be replaced by those specified in the CONFIG file.
#
$QMgrName 	= $myconfig{"QUEUEMGR"};
$QMgrName 	= $myconfig{"QUEUEMGR"}; # twice just for anti- -w luck

#
# First test the most basic instantiation.
#
# NOTE: This is in a block to allow for automatic destruction
#
{
    my $qmgr = MQSeries::QueueManager->new( QueueManager => $QMgrName );
    if ( ref $qmgr && $qmgr->isa("MQSeries::QueueManager") ) {
	print "ok 2\n";
    } else {
	print "not ok 2\n";
	exit 0;
    }
}

#
# Test the NoAutoConnect mechanism
#
{

    my $qmgr = MQSeries::QueueManager->new
      (
       QueueManager 	=> $QMgrName,
       NoAutoConnect	=> 1,
      );
    unless ( ref $qmgr && $qmgr->isa("MQSeries::QueueManager") ) {
	print "not ok 3\n";
	exit 0;
    }

    unless ( $qmgr->Connect() ) {
	print("MQSeries::QueueManager->Connect() failed.\n" .
	      "CompCode => " . $qmgr->CompCode() . "\n" .
	      "Reason   => " . $qmgr->Reason() . "\n");
	print "not ok 3\n";
	exit 0;
    }

    print "ok 3\n";

    unless ( $qmgr->Disconnect() ) {
	print("MQSeries::QueueManager->Connect() failed.\n" .
	      "CompCode => " . $qmgr->CompCode() . "\n" .
	      "Reason   => " . $qmgr->Reason() . "\n");
	print "not ok 4\n";
	exit 0;
    }

    print "ok 4\n";

}

#
# Test Open/Inquire/Close
#
{

    my $qmgr = MQSeries::QueueManager->new
      (
       QueueManager 	=> $QMgrName,
      );
    unless ( ref $qmgr && $qmgr->isa("MQSeries::QueueManager") ) {
	print "not ok 5\n";
	exit 0;
    }

    print "ok 5\n";

    unless ( $qmgr->Open() ) {
	print("MQSeries::QueueManager->Open() failed.\n" .
	      "CompCode => " . $qmgr->CompCode() . "\n" .
	      "Reason   => " . $qmgr->Reason() . "\n");
	print "not ok 6\n";
	exit 0;
    }

    print "ok 6\n";

    my %qmgrattr = $qmgr->Inquire( qw(
				      Platform
				      CodedCharSetId
				      DeadLetterQName
				     ) );

    if ( scalar keys %qmgrattr == 3 ) {
	print "ok 7\n";
    } else {
	print "MQSeries::QueueManager->Inquire did not return 3 keys\n";
	print "not ok 7\n";
    }

    my $notok8 = 0;

    if ( $qmgrattr{Platform} !~ /^\w+$/ ) {
	print "Inquired value of 'Platform' is invalid: '$qmgrattr{Platform}'\n";
	$notok8 = 1;
    }

    if ( $qmgrattr{CodedCharSetId} !~ /^\d+$/ ) {
	print "Inquired value of 'CodedCharSetId' is invalid: '$qmgrattr{CodedCharSetId}'\n";
	$notok8 = 1;
    }

    if ( $qmgrattr{DeadLetterQName} !~ /^[\w\.\s]+$/ ) {
	print "Inquired value of 'DeadLetterQName' is invalid: '$qmgrattr{DeadLetterQName}'\n";
	$notok8 = 1;
    }

    if ( $notok8 ) {
	print "not ok 8\n";
    } else {
	print "ok 8\n";
    }

    if ( $qmgr->Close() ) {
	print "ok 9\n";
    } else {
	print("MQSeries::QueueManager->Close() failed.\n" .
	      "CompCode => " . $qmgr->CompCode() . "\n" .
	      "Reason   => " . $qmgr->Reason() . "\n");
	print "not ok 9\n";
    }

}
