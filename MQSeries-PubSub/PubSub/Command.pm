#
# $Id: Command.pm,v 12.1 2000/02/03 19:44:01 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::PubSub::Command;

use strict;
use vars qw($VERSION);

$VERSION = '1.09';

use MQSeries;
use MQSeries::PubSub::Message;

sub new {

    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    # Placeholder for appropriate MQSeries::QueueManager object
    my $qmgr;

    #
    # Do this first, so we can use the ->isa() method
    #
    my $self = {};
    bless ($self, $class);

    if ( $self->isa("MQSeries::PubSub::Broker") ) {
	# We start like as a humble MQSeries::QueueManager object
	$self = MQSeries::QueueManager->new(%args) || return;
	$qmgr = $self;
    }
    elsif ( $self->isa("MQSeries::PubSub::Stream") ) {
	# Nothing else makes sense for a stream.
	$args{Mode} = 'output';
	$self = MQSeries::Queue->new(%args) || return;
	$qmgr = $self->{QueueManager};
    }
    else {
	warn("Class '$class' is not one of (or a child of):\n" .
	     "\tMQSeries::PubSub::Broker\n" .
	     "\tMQSeries::PubSub::Stream\n");
	return;
    }

    #
    # But of course, we're more than that.  We have to deal with a few
    # additional arguments.
    #
    if ( $args{DatagramOnly} ) {
	$self->{DatagramOnly} = $args{DatagramOnly};
    }
    else {
	
	#
	# The Wait argument is the length of time to wait for replies to
	# pubsub commands.
	#
	if ( $args{Wait} ) {
	    unless ( $args{Wait} =~ /^\d+$/ && $args{Wait} > 0 ) {
		$self->{Carp}->("Invalid argument: 'Wait' must be a positive integer\n");
		return;
	    }
	    $self->{Wait} = $args{Wait};
	}
	else {
	    $self->{Wait} = 5000; # 5 seconds
	}
	
	#
	# We need to know where to get the responses to pubsub commands.
	#
	# If you pass an MQSeries::Queue object, use that.  Otherwise,
	# assume its just a name, and try to create the object.  If
	# nothing is passed, then assume that a PERMDYN model queue
	# exists, and try to use that.
	#
	if ( $args{ReplyQ} ) {
	    if ( ref $args{ReplyQ} && $args{ReplyQ}->isa("MQSeries::Queue") ) {
		$self->{ReplyQ} = $args{ReplyQ};
	    }
	    else {
		unless ( 
			$self->{ReplyQ} = MQSeries::Queue->new
			(
			 QueueManager	=> $qmgr,
			 Queue 		=> $args{ReplyQ},
			 Mode		=> 'input',
			) 
		       ) {
		    $self->{Carp}->("Unable to create ReplyQ MQSeries::Queue object\n");
		    return;
		} 
	    }
	}
	else {
	    unless (
		    $self->{ReplyQ} = MQSeries::Queue->new
		    ( 
		     QueueManager	=> $qmgr,
		     Queue 		=> 'SYSTEM.DEFAULT.MODEL.PERMDYN.QUEUE',
		     DynamicQName	=> 'PUBSUB.BROKER.REPLYQ.*',
		     Mode		=> 'input',
		     CloseOptions	=> MQCO_DELETE_PURGE,
		    )
		   ) {
		$self->{Carp}->("Unable to create ReplyQ MQSeries::Queue object\n");
		return;
	    } 
	}
    }

    # Re-bless -- even though we did it above...
    bless ($self, $class);

    return $self;

}

sub _Command {

    my $self = shift;
    my ($command,%args) = @_;

    #
    # Initialize these to something reasonable.  That is, assume
    # failure.
    #
    $self->{Reason} = MQRC_UNEXPECTED_ERROR;
    $self->{CompCode} = MQCC_FAILED;

    #
    # Build the options argument...
    #
    my $options = 
      {
       Command 		=> $command,
      };

    if ( exists $args{Options} ) {
	unless ( ref $args{Options} eq 'HASH' ) {
	    $self->{Carp}->("Invalid argument: 'Options' must be a HASH reference.\n");
	    return;
	}
	$options = { %$options, %{$args{Options}} };
    }

    #
    # We have to pass through the Header if it exists
    #
    my $header = {};

    if ( exists $args{Header} ) {
	unless ( ref $args{Header} eq 'HASH' ) {
	    $self->{Carp}->("Invalid argument: 'Header' must be a HASH reference.\n");
	    return;
	}
	$header = { %$header, %{$args{Header}} };
    }

    #
    # Build the default MsgDesc plus anything passed by the caller.
    # For example, the Expiry, CorrelId, etc...
    #
    my $msgdesc = 
      {
       MsgType		=> $self->{DatagramOnly} ? MQMT_DATAGRAM : MQMT_REQUEST,
      };

    if ( exists $args{MsgDesc} ) {
	unless ( ref $args{MsgDesc} eq 'HASH' ) {
	    $self->{Carp}->("Invalid argument: 'MsgDesc' must be a HASH reference.\n");
	    return;
	}
	$msgdesc = { %$msgdesc, %{$args{MsgDesc}} };
    }

    #
    # If this is not overridden, then provide reasonable defaults for
    # the replyq.  Also, if the object was created as DatagramOnly,
    # and the MsgType was overriden back to request, then implode.
    #
    if ( $msgdesc->{MsgType} == MQMT_REQUEST ) {
	
	if ( $self->{DatagramOnly} ) {
	    $self->{Carp}->(ref $self . " object initialized for DATAGRAM use only.\n" . 
			    "Unable to send requests.\n");
	    return;
	}

	unless ( $msgdesc->{ReplyToQ} ) {
	    $msgdesc->{ReplyToQ} = $self->{ReplyQ}->ObjDesc('ObjectName');
	    $msgdesc->{ReplyToQMgr} = $self->{ReplyQ}->ObjDesc('ObjectQMgrName');
	}

    }

    #
    # Important sanity check.  If you are sending a request, then you
    # can't do the put in syncpoint.
    #
    if ( $msgdesc->{MsgType} == MQMT_REQUEST && $args{Sync} ) {
	$self->{Carp}->("Unable to send PubSub requests in syncpoint\n");
	return;
    }

    #
    # Build the request to send
    #
    my $request = MQSeries::PubSub::Message->new
      (
       MsgDesc			=> $msgdesc,
       Header			=> $header,
       Options			=> $options,
       Data			=> $args{Data} ? $args{Data} : "",
      );

    unless ( ref $request ) {
	$self->{Carp}->("Unable to create PubSub request message.\n");
	return;
    }

    #
    # Send it to the broker.  Note that we just return here on
    # failure.  The Put or Put1 method will whine about the problem,
    # and set CompCode and Reason.
    #
    my $putmethod = "Put";
    my $putargs = 
      {
       Message			=> $request,
      };

    if ( exists $args{PutArgs} ) {
	unless ( ref $args{PutArgs} eq 'HASH' ) {
	    $self->{Carp}->("Invalid argument: 'PutArgs' must be a HASH reference.\n");
	    return;
	}
	$putargs = { %$putargs, %{$args{PutArgs}} };
    }

    if ( $self->isa("MQSeries::PubSub::Stream") ) {
	$putargs = 
	  { 
	   %$putargs,
	   Sync			=> $args{Sync},
	  };
    }
    else {
	# Must be an MQSeries::PubSub::Broker then...
	$putargs = 
	  { 
	   %$putargs,
	   Queue		=> 'SYSTEM.BROKER.CONTROL.QUEUE',
	  };
	$putmethod = "Put1";
    }

    $self->$putmethod(%$putargs) || return;

    #
    # If we sent a datagram, then we're done.  No further error
    # checking.
    #
    return $request if $msgdesc->{MsgType} == MQMT_DATAGRAM;

    #
    # Reset these to assume failure, since a successful Put1() call
    # will set them to assume success.
    #
    $self->{Reason} = MQRC_UNEXPECTED_ERROR;
    $self->{CompCode} = MQCC_FAILED;

    my $response = MQSeries::PubSub::Message->new
      (
       MsgDesc			=>
       {
	CorrelId		=> $request->MsgDesc('MsgId'),
       },
      );

    unless ( ref $response ) {
	$self->{Carp}->("Unable to create PubSub response message.\n");
	return;
    }

    my $get = $self->{ReplyQ}->Get
      (
       Message			=> $response,
       Wait			=> $self->{Wait},
      );

    unless ( $get > 0 ) {
	$self->{Carp}->("No response from broker for command '$command'\n");
	$self->{Reason} = $self->{ReplyQ}->{Reason};
	$self->{CompCode} = $self->{ReplyQ}->{CompCode};
	return;
    }

    #
    # Finally, set the reason/compcode to match those in the response,
    # and save the response (usually won't need it, but ya never
    # know...)
    #
    $self->{Reason} = $response->Options('Reason');
    $self->{CompCode} = $response->Options('CompCode');
    $self->{Response} = $response;

    if ( $self->{Reason} == MQCC_OK && $self->{CompCode} == MQRC_NONE ) {
	return 1;
    }
    else {
	# Don't carp here.  Some reason codes are expected.  For
	# example, MQRCCF_NO_RETAINED_MSG may be OK, just like
	# MQRC_NO_MSG_AVAILABLE.  Let the application decide.
	return;
    }

}

sub Response {
    my $self = shift;
    return $self->{Response};
}

sub ReplyQ {
    my $self = shift;
    if ( exists $self->{ReplyQ} ) {
	return $self->{ReplyQ};
    }
    else {
	return;
    }
}

1;

__END__

=head1 NAME

MQSeries::PubSub::Command -- base OO class implementing and interface to the MQSeries Publish/Subscribe broker commands.

=head1 SYNOPSIS

  #
  # Examples of Broker object instantiation
  #
  # Plain and simple (usually sufficient)
  #
  my $broker = MQSeries::PubSub::Broker->new
    ( 
     QueueManager 		=> 'FOO.QMGR' 
    ) || die;

  #
  # Using your own ReplyQ.
  #
  my $replyq = MQSeries::Queue->new
    (
     QueueManager		=> $broker,
     Queue			=> 'SOME.APP.MODEL.QUEUE'
     DynamicQName		=> 'SOME.APP.REPLYQ.*',
     Mode			=> 'input',
     CloseOptions		=> MQCO_DELETE_PURGE,
    ) || die;

  my $broker = MQSeries::PubSub::Broker->new
    (
     QueueManager		=> 'FOO.QMGR',
     ReplyQ			=> $replyq,
    ) || die;

  #
  # Using a fixed, per-defined app-specific local queue
  #
  my $broker = MQSeries::PubSub::Broker->new
    (
     QueueManager		=> 'FOO.QMGR',
     ReplyQ			=> 'SOME.APP.PUBSUB.REPLY',
    ) || die;

  #
  # Examples of Stream object instantiation
  # 
  my $stream = MQSeries::PubSub::Stream->new
    (
     QueueManager		=> $broker,
     Queue			=> 'SOME.APP.PUBSUB.STREAM',
    ) || die;

  #
  # Command examples
  #  
  # RegisterPublisher, single topic
  #
  $broker->RegisterPublisher
    (
     Options			=>
     {
      Topic			=> 'Some/Topic/Of/Interest',
      StreamName		=> 'SOME.APP.PUBSUB.STREAM',
     },
    ) || die;


  #
  # RegisterSubscriber, multiple topics
  #
  $broker->RegisterSubscriber
    (
     Options			=> 
     {
      Topic			=> [qw(
				       Some/Topic/Of/Interest
				       Other/Interesing/Topic
				       Something/Boring
				      )],
      StreamName		=> 'SOME.APP.PUBSUB.STREAM',
     },
    ) || die;

  #
  # RegisterSubscriber, with subscription expiration
  #
  $broker->RegisterSubscriber
    (
     MsgDesc			=>
     {
      Expiry			=> 600,
     },
     Options			=>
     {
      Topic			=> 'Some/Topic/Of/Interest',
      StreamName		=> 'SOME.APP.PUBSUB.STREAM',
     },
    ) || die;

  #
  # RegisterSubscriber, with your own replyQ
  #  
  my $replyq = MQSeries::Queue->new
    (
     QueueManager		=> $broker,
     Queue			=> 'SOME.APP.MODEL.QUEUE'
     DynamicQName		=> 'SOME.APP.REPLYQ.*',
     Mode			=> 'input',
     CloseOptions		=> MQCO_DELETE_PURGE,
    ) || die;

  $broker->RegisterSubscriber
    (
     Options			=>
     {
      Topic			=> 'Some/Topic/Of/Interest',
      StreamName		=> 'SOME.APP.PUBSUB.STREAM',
      QMgrName			=> $replyq->ObjDesc('ObjectQMgrName'),
      QName			=> $replyq->ObjDesc('ObjectName'),
     },
    ) || die;

  #
  # Publish some data
  #
  $stream->Publish
    (
     Options			=>
     {
      Topic			=> 'Some/Topic/Of/Interest',
     },
     Data			=> $mydata,
    ) || die;

  #
  # Publish some data as a datagram, explicitly.  Note that the data
  # is a string, so we set the Format field of the MQRFH header
  # appropriately.
  #
  $stream->Publish
    (
     MsgDesc			=>
     {
      MsgType			=> MQMT_DATAGRAM,
     },
     Header			=>
     {
      Format			=> MQFMT_STRING,
     },
     Options			=>
     {
      Topic			=> 'Some/Topic/Of/Interest',
     },
     Data			=> $mydata,
    ) || die;

=head1 DESCRIPTION

The MQSeries::PubSub::Command class is the base class for both of
MQSeries::PubSub::Broker and MQSeries::PubSub::Stream.  It is not used
directly, and attempts to instantiate MQSeries::PubSub::Command
objects will fail.

The underlying similarity between both objects is that they implement
subsets of the Publish/Subscribe commands.  There are 7 of these
commands, and 5 of them are specific to the PubSub Broker
(QueueManager), and 2 to any individual PubSub Stream (Queue).

  PubSub Command	Module
  --------------	------
  RegisterPublisher	MQSeries::PubSub::Broker
  RegisterSubscriber	MQSeries::PubSub::Broker
  DeregisterPublisher	MQSeries::PubSub::Broker
  DeregisterSubscriber	MQSeries::PubSub::Broker
  RequestUpdate		MQSeries::PubSub::Broker
  Publish		MQSeries::PubSub::Stream
  DeletePublication	MQSeries::PubSub::Stream

This base class (MQSeries::PubSub::Command) implements the command
interface, with the fundamental difference being the MQSeries Queue to
which the command messages are put.  The Broker-specific commands all
put messages to the SYSTEM.BROKER.CONTROL.QUEUE, and the
Stream-specific commands put messages to the chosen PubSub stream.  In
both case, the broker should be listening on these queues, and it
expects the same format (MQRFH) for the messages, and generates
replies accordingly.

In addition, this API provides for several "Extended Commands", which
are convenience functions allowing the developer to query the
Publish/Subscribe administrative messages in the "MQ/*" topic
namespace for each Stream.  All of these commands are methods of the
MQSeries::PubSub::Broker object.

  PubSub Extended Command
  -----------------------
  InquireParent
  InquireChildren
  InquireStreamNames
  InquireTopics
  InquireIdentities
  InquireRetainedMessages

=head1 METHODS

MQSeries::PubSub::Broker objects are subclassed from
MQSeries::QueueManager, and therefore all of the latter methods are
available. 

MQSeries::PubSub::Stream objects are subclassed from MQSeries::Queue,
and therefore all of the latter methods are available.  However, it
should be noted that an MQSeries::PubSub::Stream object can only be
opened for 'output', since input is the PubSub brokers responsibility
(that is, the actual broker process, not the perl5 Broker object).
More importantly, messages must be put using the Publish method,
rather then Put directly, since the format must be a proper MQRFH
message.  This is handled automatically, if the Publish method is
used.  Gluttons for punishment are welcome to do this on their own.

The return value from all of the command methods depends on whether or
not datagrams or requests are being sent.  In all cases, the command
methods return a false value in any failure scenario.  When succesful,
the result is always true, and if datagrams are sent, the return value
is the MQSeries::PubSub::Message object successfully put to either the
SYSTEM.BROKER.CONTROL.QUEUE or the MQSeries::PubSub::Stream queue.

When sending datagrams, one may still wish to know the MsgId of the
successfully put messages, for later correlation with exception
reports for example.  The API provided by these classes does nothing
special to handle these reports; it is the responsibility of the
application to poll any ReplyQ for these, and correlate the exception
reports with the original messages.  By returning the
MQSeries::PubSub::Message object, this is at least possible.

=head2 new

In addition to the documented arguments of the parent class
constructors, the MQSeries::PubSub::Broker and
MQSeries::PubSub::Stream constructor supports some additional
arguments.

  Key	        Value
  ===           =====
  ReplyQ        String, or MQSeries::Queue object
  Wait          Numeric
  DatagramOnly  Boolean

=over 4

=item ReplyQ

If specified, this can either be a plain string, in which case it is
interpreted as queue name to be opened for input, or it can be an
MQSeries::Queue object (or subclass thereof), in which case it is
assumed to have been instantiated for input.

If not given (and if DatagramOnly is omitted), the constructor will
open a permanent dynamic queue, using the
SYSTEM.DEFAULT.MODEL.PERMDYN.QUEUE model queue, and
PUBSUB.BROKER.REPLYQ.* as a DynamicQName template.  

NOTE: This queue is not a default object created by the MQSeries
product, so it will need to be created by the MQSeries administrators
at your site, if you wish to leverage this feature.

The dynamic queue is opened by specifying MQCO_DELETE_PURGE as a
CloseOptions, so it should be destroyed when the broker object goes
out of scope, or the perl process exits.

This queue will be used as the reply queue for request messages sent
to the broker, or published to a stream queue.

=item Wait

This parameter specified the Wait argument passed to the Get() method
when retreiving responses from the broker.  This is obviously not
relevant if the DatagramOnly option is set, or if the individual
MQSeries::PubSub::Message objects are instantiated as datagrams, and
not requests.

The default value is 5000 milliseconds.

=item DatagramOnly

If this is true, then the broker will be configured to always send
datagrams, and never requests, when sending messages to the broker.
By specifying that the user intends to send nothing other than
datagrams, the automatic creation of a dynamic reply queue is
disabled, since it will not be needed.

This simply optmization would really only be appropriate for a high
performance publisher sending non-persistent messages via the PubSub
infrastructure.

The use of only datagrams implies a significantly reduced level of
error checking, since the only operation that can be checked is the
MQPUT() of the messages to either the broker control queue, or an
individual stream queue.  If the broker encounters a problem when it
retreives such a message, it may be silently dropped, or perhaps sent
to the system dead letter queue, depending on the configuration of the
broker.

In any event, this feature should be used with caution.

=back

=head2 Response

This method returns the MQSeries::PubSub::Message object for the
response retrieved from the broker, which will be saved in the object,
unless the command sent a datagram.  See the MQSeries::PubSub::Message
for more information.

=head2 ReplyQ

This method returns the MQSeries::Queue object instantiated for the
ReplyQ used by the Broker of Stream object.  This would be useful if
the subscriber queue is allowed to default to the automatically
created and opened object created at instantiation time.  If the
application doesnt create its own subscriber queue, for example.  When
RegisterSubscriber is called, the QMgrName and QName Options can be
omitted, and they will default to those used in the MsgDesc field of
the resulting command message, which will be set to those of the
automatically instantiated ReplyQ object by default.

Publications will then be sent to the default ReplyQ, and applications
can use this method to retrieve the object against which the Get
method call must be retrieve the subscribed data.

For example:

  $broker = MQSeries::PubSub::Broker->new( QueueManager => 'FOO' ) || die;
  $broker->RegisterSubscriber
    (
     Options			=>
     {
      Topic			=> 'Something/Interesting',
      StreamName		=> 'SOME.APP.STREAM',
     },
    ) || die;

  while ( 1 ) {

      my $message = MQSeries::PubSub::Message->new() || die;
      my $result = $broker->ReplyQ()->Get
        ( 
         Message 		=> $message,
         Wait			=> 1000,
        );
 
      next if $result > 1; # -1 means MQRC_NO_MSG_AVAILABLE -- see MQSeries::Queue::Get docs
     
      # Do something useful with $message->Data(), perhaps
    
  }

=head1 COMMAND SYNTAX

All 7 of the Publish/Subscribe commands have a common calling syntax.
These are all implemented as method calls of either
MQSeries::PubSub::Broker or MQSeries::PubSub::Stream objects, as
discussed above.

=head2 Common Arguments

The arguments to the command methods are a hash, containing the
following Key/Value pairs:

  Key			Value
  ===			=====
  MsgDesc		MQMD HASH ref (see MQSeries::Message->new() docs)
  Header		MQRFH HASH ref (see MQSeries::Message::RulesFormat->new() docs)
  Options		PubSub command NameValue pairs (MQRFH.NameValueString, see below)
  Data			Scalar value, passed to MQSeries::PubSub::Message->new()
  Sync			Boolean, passed to MQSeries::Queue->Put()

=over 4

=item MsgDesc

This HASH is passed through directly to the
MQSeries::Message::RulesFormat->new() constructor, however there are a
few keys that are particularly important.

"Format" should not be given, as this will be set to MQFMT_RF_HEADER
by default (which is actually the required format for PubSub
commands), when the underlying MQSeries::PubSub::Message object is
instantiated.  This is done for you.

"Expiry" will be both the expiration value for the message itself, as
well as the expiration of the publication or subscription
registration.  This value will typically be used to specify the
lifetime of the PubSub subscriber or publisher aopplication.

"MsgType" can be set to either MQMT_DATAGRAM or MQMT_REQUEST, with the
default depending on how the MQSeries::PubSub::* object was
instantianted.  If the DatagramOnly option was specified, then it is
an error to attempt to send a MQMT_REQUEST.  MsgType defaults to
MQMT_REQUEST, unless DatagramOnly was specified, in which case it
defaults to MQMT_DATAGRAM.

"ReplyToQ" and "ReplyToQMgr", if not given, are assumed to be the
those of the "ReplyQ" opened when the MQSeries::PubSub::* object was
instantiated, but they can be specified, and thus override these
defaults.  Normally, the developer specifies the ReplyQ at
instantiation time, and not for each and every PubSub command, so thee
options are not normally used.

=item Header

This HASH is passed through directly to the
MQSeries::Message::RulesFormat->new() constructor.  This HASH
represents all of the fields of the MQRFH data structure, except the
NameValue string (see the "Options" section below).

In general, all of the fields of this data structure have reasonable
defaults, and the only fields that usually need to be set, if at all,
are as follows.

"Encoding" defaults to MQENV_NATIVE, but this can be set if your
application uses the pre-defined numeric data formats supported by
MQSeries.

"CodedCharSetId" defaults to MQCCSI_Q_MGR, but can be set to the
appropriate value when string data is used, and a specific character
set is used.

"Format" defaults to MQFMT_NONE, which is wrong if you are using
string data in your publications.  In order for MQGMO_CONVERT to work
correctly, this field must be set to MQFMT_STRING for string data.

=item Options

This is a HASH or Name/Value pairs, which represents the MQRFH
NameValue string.  The keys vary from one command to another, and are
documented in detail in the "MQSeries PubSub Users Guide" document
from IBM.  They are summarized here for completeness.

Most of the values should be simple strings, corresponding to the
value of that Options key.  However, if the Key is repeated (for
example, specifying multiple topics for a subscription), then value
should be an ARRAY reference of strings.  This will generate an
appropriately repeated entry in the NameValue string section of the
resulting MQRFH message.

Most importantly, in the documentation, the key strings are all
prefixed with "MQPS".  This must be omitted, as the
MQSeries::PubSub::Message objects will prepend it appropriately, and
strip it when retreiving these messages.

See below for a summary of each individual PubSub commands options.  

=item Sync

This option is passed directly to the MQSeries::Queue->Put() method,
and it can only really be used when sending datagrams.  Obviously, if
you are sending requests, then you can not use syncpoint since the put
of the request, and subsequent get of the response all happens within
a single subroutine call.  

This option is really only relevant if MsgDesc->{MsgType} ==
MQMT_DATAGRAM, and then the method call (eg. the
MQSeries::PubSub::Broker->Commit() call) is the responsibility of the
calling application.

=item Data

This is application data portion of the subsequently instantiated
MQSeries::PubSub::Message object.  See the
MQSeries::Message::RulesFormat documentation for more information.

=back

=head1 COMMANDS

This section provides a summary of the Options keys, and appropriate
values, for each of the 7 PubSub commands.  Note that the full story
here is really found in the IBM product documentation, most notably
the "MQSeries PubSub User's Guide".

NOTE: that the docs list the "Command" key as required, but you will
notice it is omitted here.  Since the method names all map directly to
the actual command name, this API adds that key for you.  

=head2 RegisterPublisher (Broker)

  Required keys: 
	Topic 
  Optional keys: 
	RegOpts, StreamName, QMgrName, QName

=head2 RegisterSubscriber (Broker)

  Required parameters: 
	Topic 
  Optional parameters: 
	RegOpts, StreamName, QMgrName, QName

=head2 DeregisterPublisher (Broker)

  Optional parameters: 
	RegOpts, StreamName, Topic, QMgrName, QName

=head2 DeregisterSubscriber (Broker)

  Optional parameters: 
	RegOpts, StreamName, Topic, QMgrName, QName

=head2 RequestUpdate (Broker)

  Required parameters: 
	Topic 
  Optional parameters: 
	RegOpts, StreamName, QMgrName, QName

=head2 Publish (Stream)

  Required parameters: 
	Topic 
  Optional parameters: 
	RegOpts, PubOpts, StreamName, 
	QMgrName, QName, PubTime, SeqNum, 
	StringData, IntData

Data can be published in any arbitrary string format, using the Data
argument to the Publish command (see above).

NOTE: The version of the IBM docs I have has an important typo, namely
the PublishTimestamp section for this command claims the Name: is
MQPSQName, and the string constant is MQPS_Q_NAME, which is obviously
wrong.

=head2 DeletePublication (Stream)

  Required parameters: 
	Topic 
  Optional parameters: 
	DelOpts, StreamName

=head1 EXTENDED COMMANDS

WARNING: These commands are entirely specific to the MQSeries
Publish/Subscribe Perl API, and there is no analogous functionality in
any of the IBM products or APIs.  These commands are modeled after the
Command Server API (MQSeries::Command) methods, in terms of the names
chosen.

=head2 InquireParent

This method returns a single string, which is the name of the parent
broker for the given queue manager.  The arguments are a hash of
key/value pairs:

  Key		Value
  ===		=====
  QMgrName	string

=over 4

=item QMgrName

This is the name of the queue manager whose parent is being queried.
This argument is optional, and the QMgrName defaults to the same queue
manager as that used to instantiate the MQSeries::PubSub::Broker
object.

=back

=head2 InquireChildren

This method returns a list of strings, each of which is a broker queue
manager whose parent is the given queue manager.  The arguments are a
hash of key/value pairs:

  Key		Value
  ===		=====
  QMgrName	string

=over 4

=item QMgrName

This is the name of the queue manager whose children are being
queried.  This argument is optional, and the QMgrName defaults to the
same queue manager as that used to instantiate the
MQSeries::PubSub::Broker object.

=back

=head2 InquireStreamNames

This method returns a list of strings, each of which is a supported
StreamName, available on the broker for the given queue manager. The
arguments are a hash of key/value pairs:

  Key		Value
  ===		=====
  QMgrName	string

=over 4

=item QMgrName

This is the name of the queue manager whose stream names are being
queried.  This argument is optional, and the QMgrName defaults to the
same queue manager as that used to instantiate the
MQSeries::PubSub::Broker object.

=back

=head2 InquireTopics

This method returns a list of strings, each of which is a currently
registered Topic, for either Publishers or Subscribers, for the given
QMgrName and StreamName.  The
arguments are a hash of key/value pairs:

  Key		Value
  ===		=====
  Type		string ( "Publishers" | "Subscribers" )
  StreamName	string
  QMgrName	string

=over 4

=item Type

This indicates whether registered Publishers or Subscribers Topics are
to be queried.  It is optional, and defaults to "Publishers", in the
assumption that the available Topic list is most interesting.

=item StreamName

This indicates the stream for which Topics are to be queried.  It is
optional, and defaults to "SYSTEM.BROKER.DEFAULT.STREAM".

=item QMgrName

This is the name of the queue manager whose topics are being queried.
This argument is optional, and the QMgrName defaults to the same queue
manager as that used to instantiate the MQSeries::PubSub::Broker
object.

=back

=head2 InquireIdentities

This method returns a list of hash references, each of which describes
the publishers or subscribers for a single stream.  The arguments are
a hash of key/value pairs:

  Key		Value
  ===		=====
  Type		string ( "Publishers" | "Subscribers" )
  QMgrName	string
  Topic		string
  StreamName	string
  Anonymous	Boolean

=over 4

=item Type

This is a string which indicates whether the query if for "Publishers"
or "Subscribers".  This argument is optional, and at defaults to
"Subscribers".

=item QMgrName

This is the name of the queue manager whose publishers are being
queried.  This argument is optional, and the QMgrName defaults to the
same queue manager as that used to instantiate the
MQSeries::PubSub::Broker object.

=item Topic

This is the Topic for which publishers are being queried.  This
argument is optional, and it defaults to '*', or all possible topics.

=item StreamName

This is the stream name for which publishers are being queried.  This
argument is optional and it defaults to
"SYSTEM.BROKER.DEFAULT.STREAM".

=item Anonymous

This is a flag which indicated whether or not anonymous publishers are
to be included in the returned data.

=back

The structure of the return data for the InquireIdentities method is
as follows.  The return value is an ARRAY of HASH references.  Each
HASH has the following keys:

  Key			Value
  ===			=====
  Topic			string
  StreamName		string
  BrokerCount		integer
  ApplCount		integer
  AnonymousCount	integer
  Publishers		ARRAY reference
  Subscribers		ARRAY reference

There will be one of these HASH references for each Topic which
matches the value specified in the method argument list.

=over 4

=item Topic

The Topic for which this entry contains publisher or subscriber
information.  

=item StreamName

The StreamName for which this entry contains publisher or subscriber
information.  

=item BrokerCount

Count of publisher or subscriber registrations from brokers.  For
publishers, this count is normally zero, as brokers do not register as
publishers. The role of a broker in acting as a publisher itself for
metatopics on stream queues is not counted, nor is its role as a
publisher for administrative topics on the SYSTEM.BROKER.ADMIN.STREAM
stream.

=item ApplCount

Count of publisher or subscriber registrations from applications.
Note that this includes anonymous registrations if the "Anonymous"
argument was given.

=item AnonymousCount

Count of anonymous publisher or subscriber registrations from
applications.

=item Publishers or Subscribers

Only one of these keys will be present, obviously depending on the
value of the "Type" specified in the method argument list.  The value
will be an ARRAY reference of HASH references.  There will be one
entry in the ARRAY for each individual publisher or subscriber.

=back

The Publishers and/or Subscribers HASH references will have the
following keys:

  Key			
  ===			
  QMgrName		
  QName
  UserIdentifier
  RegistrationOptions
  Time
  CorrelId

NOTE: These are the same as the Parameter identifiers documented in
the IBM docs with the string "Registration" prepended.   

=over 4

=item QMgrName

Publisher's or subscriber's queue manager name.

=item QName

Publisher's or subscriber's queue name.

=item UserIdentifier

Publisher's or subscriber's user ID.

=item RegistrationOptions

This is a HASH reference, and the existence of any of the following
keys indicated that the corresponding RegistrationOptions value is
present.

For publishers, the following keys may be present:

  Key			Option
  ===			======
  Anon			MQREGO_ANONYMOUS
  Local			MQREGO_LOCAL
  DirectReq		MQREGO_DIRECT_REQUEST
  CorrelAsId		MQREGO_CORREL_ID_AS_IDENTITY
  
For subscribers, the following keys may be present:

  Key			Option
  ===			======
  Anon			MQREGO_ANONYMOUS
  Local			MQREGO_LOCAL
  NewPubsOnly		MQREGO_NEW_PUBLICATIONS_ONLY
  PubOnReqOnly		MQREGO_PUBLISH_ON_REQUEST_ONLY
  CorrelAsId		MQREGO_CORREL_ID_AS_IDENTITY
  InclStreamName	MQREGO_INCLUDE_STREAM_NAME
  InformIfRet		MQREGO_INFORM_IF_RETAINED

=item Time

Time of registration.

=item CorrelId

Publisher's or subscriber's correlation identifier.

This is a 48-byte character string of hexadecimal characters
representing the contents of the 24-byte binary correlation
identifier. Each character in the string is in the range 0 through 9
or A through F. 

This parameter is present only if the publisher's or subscriber's
identity includes a correlation identifier.

=back

=head2 InquireRetainedMessages

This method is really the building block for all of the above
"Extended Commands", however it is also useful as a standalone method
for querying arbitrary Publish/Subscribe administrative messages.
Note that for some of the specific information available, the higher
level functions described above should be used.

This code works by calling RegisterSubscriber with for the specified
Topic and StreamName, retreives all of the retained publications by
calling RequestUpdate, and finally calls DeregisterSubscriber to
cancel the subscription.

This method will return an array of MQSeries::PubSub::AdminMessage
objects, one for each retained message in the specifies Topic and
StreamName.  The arguments are a hash of key/value pairs:

  Key			Value
  ===			=====
  Topic			string
  StreamName		string

=over 4

=item Topic

This is the Topic for which retained messages are to be queried.

=item StreamName

This is the StreamName for which retained messages are to be queried.
This is optional, and the default value is
"SYSTEM.BROKER.ADMIN.STREAM".

=back

=head1 SEE ALSO

MQSeries::PubSub::Broker(3), MQSeries::PubSub::Stream(3), MQSeries::PubSub::Message(3),
MQSeries::QueueManager(3), MQSeries::Queue(3),
"MQSeries PubSub User's Guide"

=cut
