#!/ms/dist/perl5/bin/perl5.005
#
# $Id: amqspsda.pl,v 10.1 1999/11/11 18:43:37 wpm Exp $

use strict;
use English;

use Getopt::Long;

use MQSeries;
use MQSeries::PubSub::Broker;
use MQSeries::PubSub::Stream;
use MQSeries::PubSub::AdminMessage;

require 'ctime.pl';

#
# Global Variables
#
$::QMgrName 		= '';
$::StreamName 		= '*';
$::QName 		= '';
$::LogFileName 		= '';
$::Topic 		= '*';
$::RetainedTopic 	= '';
$::PubOnly		= 0;
$::SubOnly		= 0;
$::Anonymous		= 0;

$::Expiry		= 300;
$::DefaultWait  	= 8000;		# 8 seconds
$::ExtendedWait  	= 300000; 	# 5 minutes

$::AdminStream		= "SYSTEM.BROKER.ADMIN.STREAM";
$::ModelQueue		= "AMQSPSD.PERMDYN.MODEL.QUEUE";

#
# "Main" starts here...
#
{
    
    GetArgs();
    OpenLog();

    my $date = ctime(time);
    print <<"EndOfText";

MQSeries Message Broker Dumper
Start time: $date
EndOfText

    #
    # Instantiate the MQSeries::QueueManager object, and Connect to
    # the queue manager
    #
    my $QMgrObj = MQSeries::QueueManager->new
      ( 
       QueueManager 	=> $::QMgrName,
       NoAutoConnect	=> 1,
      ) || Die("Unable to instantiate MQSeries::QueueManager object!");

    $QMgrObj->Connect() ||
      Die("Unable to connect to queue manager $::QMgrName",$QMgrObj);


    #
    # We need to know the name of the queue manager for topic
    # subscription, if one was not supplied as a parameter we must
    # 'inquire' it from the queue manager.
    #
    unless ( $::QMgrName ) {

	$QMgrObj->Open() ||
	  Die("Unable to Open queue manager for inquiry",$QMgrObj);

	my %QMgrAttrs = $QMgrObj->Inquire("QMgrName") ||
	  Die("Unable to inquire QMgrName",$QMgrObj);

	$::QMgrName = $QMgrAttrs{QMgrName};

	$QMgrObj->Close() ||
	  Die("Unable to Close queue manager",$QMgrObj);

    }

    #
    # Now this is where the perl versions starts to really get simple
    # when compared to the C version
    #
    if ( $::QName ) {
	$::ReplyQObj = MQSeries::Queue->new
	  (
	   QueueManager		=> $QMgrObj,
	   Queue		=> $::QName,
	   Mode			=> 'input',
	  ) || Die("Unable to instantiate MQSeries::Queue object");
    }
    else {
	$::ReplyQObj = MQSeries::Queue->new
	  (
	   QueueManager		=> $QMgrObj,
	   Queue		=> $::ModelQueue,
	   DynamicQName		=> "AMQSPSDA.*",
	   Mode			=> 'input',
	   CloseOptions		=> MQCO_DELETE_PURGE,
	  ) || Die("Unable to instantiate MQSeries::Queue object");
    }

    #
    # Instantiate the Broker object
    #
    $::BrokerObj = MQSeries::PubSub::Broker->new
      (
       QueueManager		=> $::QMgrName,
       ReplyQ			=> $::ReplyQObj,
      ) || Die("Unable to instantiate MQSeries::PubSub::Broker object");

    #
    # Dump out the parent/child relationships 
    #
    DumpRelations();
    
    if ( $::StreamName eq '*' ) {
	@::StreamNames = $::BrokerObj->InquireStreamNames();

        print <<"EndOfText";

Streams supported
-----------------
EndOfText

	foreach my $streamname ( @::StreamNames ) {
	    print "   $streamname\n";
	}

    }
    else {
	@::StreamNames = ($::StreamName);
    }

    unless ( $::SubOnly ) {
	DumpPublishersOrSubscribers("Publishers");
    }

    unless ( $::PubOnly ) {
	DumpPublishersOrSubscribers("Subscribers");
    }

    if ( $::RetainedTopic ) {
	DumpRetainedMessages();
    }

}

exit 0;

#
# 
#
sub GetArgs {
    
    my (%args) = ();

    GetOptions( \%args, qw( m=s q=s s=s l=s t=s p u a r=s ) )
      || die "Error parsing \@ARGV\n";
    
    if ( exists $args{m} ) {
	if ( length($args{m}) <= MQ_Q_MGR_NAME_LENGTH ) {
	    $::QMgrName = $args{m};
	}
	else {
	    Usage("[-m] QMgrName too long, max length " . MQ_Q_MGR_NAME_LENGTH);
	}
    }

    if ( exists $args{q} ) {
	if ( length($args{q}) <= MQ_Q_NAME_LENGTH ) {
	    $::QName = $args{q};
	}
	else {
	    Usage("[-q] QName too long, max length " . MQ_Q_NAME_LENGTH);
	}
    }

    if ( exists $args{s} ) {
	if ( length($args{s}) <= MQ_Q_NAME_LENGTH ) {
	    $::StreamName = $args{s};
	}
	else {
	    Usage("[-s] StreamName too long, max length " . MQ_Q_NAME_LENGTH);
	}
    }

    $::LogFileName = $args{l} 	if exists $args{l};
    $::Topic = $args{t} 	if exists $args{t};

    $::PubOnly = 1 		if exists $args{p};
    $::SubOnly = 1 		if exists $args{u};
    $::Anonymous = 1 		if exists $args{a};
    
    if ( exists $args{r} ) {
	warn "Dumping retained messages is not yet supported\n";
	$::RetainedTopic = $args{r} if exists $args{r};
    }


}

sub Usage {

    my ($message) = @_;

    die <<"EndOfUsage";
$message

Usage: amqspsda [ -m <QMgrName> ]
                [ -q <QName> ]
                [ -s <StreamName> ]
                [ -l <LogFileName> ]
                [ -t <Topic> ]
                [ -p ] Dump information for publishers only
                [ -u ] Dump information for subscribers only
                [ -a ] Dump information for anonymous publishers/subscribers
                [ -r <RetainedTopic> ] Dump retained messages
EndOfUsage

}

sub OpenLog {

    return 1 unless $::LogFileName;

    open("LOGFILE",">>$::LogFileName") ||
      die "Unable to open $::LogFileName: $ERRNO\n";
    select(LOGFILE); $| = 1;

    return 1;

}

sub Die {

    my ($message,$object) = @_;

    $message .= "\n" unless $message =~ /\n$/;

    if ( ref $object ) {
	#
	# Why seperate these?  Well, just in case the $object is NOT a
	# valie object (internal error), we'll still see the $message,
	# before perl vomits 'cause of the misuse of $object.  But hey,
	# we're dying anyway....
	#
	warn($message);
	die("CompCode => " . $object->CompCode() . "\n" .
	    "Reason   => " . $object->Reason() . "\n");
    }
    else {
	die($message);
    }

}

sub DumpRelations {

    print <<"EndOfText";
Broker Relations
----------------
QMgrName:
   $::QMgrName
Parent:
EndOfText

    my $parent = $::BrokerObj->InquireParent() || "None";
    
    print "   $parent\n";
    
    my (@children) = $::BrokerObj->InquireChildren();
		      
    print "Children:\n";
    
    if ( @children ) {
	foreach my $child ( @children ) {
	    print "   $child\n";
	}
    }
    else {
	print "   None\n";
    }

}

sub DumpPublishersOrSubscribers {

    my ($type) = @_;
    
    print "\n$type\n" . '-' x length($type) . "\n";
    
    foreach my $streamname ( @::StreamNames ) {

	print "\nStreamName: $streamname\n";

	my (@identities) = $::BrokerObj->InquireIdentities
	  (
	   Anonymous	=> $::Anonymous,
	   StreamName	=> $streamname,
	   Type		=> $type,
	  );

	if ( 
	    $::BrokerObj->Reason() != MQRC_NONE && 
	    $::BrokerObj->Reason() != MQRCCF_NO_RETAINED_MSG ) {
	    Die("Unable to InquireIdenties\n",$::BrokerObj);
	}

	unless ( @identities ) {
	    print "   None\n";
	    next;	    
	}

	foreach my $identitylist ( @identities ) {

	    print "\n";
	    print "   Topic: $identitylist->{Topic}\n";
	    print "      BrokerCount: $identitylist->{BrokerCount}\n";
	    print "      ApplCount: $identitylist->{ApplCount}\n";
	    print "      AnonymousCount: $identitylist->{AnonymousCount}\n";

	    foreach my $identity ( @{$identitylist->{$type}} ) {

		print "\n";

		foreach my $key (
				 qw(
				    QMgrName
				    QName
				    UserIdentifier
				    RegistrationOptions
				    Time
				    CorrelId
				   )
				) {

		    next unless exists $identity->{$key};

		    if ( ref $identity->{$key} eq 'HASH' ) {
			if ( keys %{$identity->{$key}} ) {
			    print("         $key: " . 
				  join(" ",sort keys %{$identity->{$key}}) . 
				  "\n");
			}
			else {
			    print "         $key: None\n";
			}
		    }
		    else {
			print "         $key: $identity->{$key}\n";
		    }
		    
		}

	    }

	}

    }    

}

#
# This is, well, a bit hard, because the OO API doesn't let you
# redefine the object type on the fly.  You have to "know" what class
# of message you are about to get, otherwise the GetConvert method
# fails, and you're SOL.
#
# In 1.07, I'll almost certainly add the ability to use
# MQSeries::Message, and have the API figure out what class to promote
# the object to, automatically.
#
sub DumpRetainedMessages {
    1;
}
