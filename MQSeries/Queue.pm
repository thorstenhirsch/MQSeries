#
# $Id: Queue.pm,v 11.2 2000/02/02 23:08:59 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Queue;

require 5.004;

use strict qw(vars refs);
use Carp;
use English;

use MQSeries;
use MQSeries::QueueManager;
#
# Well, now that we're using the same constants for the Inquire/Set
# interface, they no longer are really part of the Command/PCF
# heirarchy.  We may or may not address this namespace asymmetry in a
# future release.
#
use MQSeries::Command::PCF;

use vars qw($VERSION);

$VERSION = '1.08';

sub new {
    
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    my %ObjDesc = ();

    #
    # Note -- because we have a ObjDesc method, we'd have to 
    # quote the ObjDesc key everywhere, so...
    #
    my $self = {
		Options		=> MQOO_FAIL_IF_QUIESCING,
		ObjDescPtr 	=> \%ObjDesc,
		Carp 		=> \&carp,
		RetryCount	=> 0,
		RetrySleep 	=> 0,
	       };
    bless ($self, $class);

    #
    # First thing -- override the Carp routine if given.
    #
    if ( $args{Carp} ) {
	if ( ref $args{Carp} ne "CODE" ) {
	    carp "Invalid argument: 'Carp' must be a CODE reference";
	    return;
	}
	else {
	    $self->{Carp} = $args{Carp};
	}
    }

    #
    # We'll need a Queue Manager, one way or another.
    #
    # NOTE: if nothing is given, then the MQSeries::QueueManager
    # constructor will assume you want the "default" QM.
    #
    if ( ref $args{QueueManager} ) {
	if ( $args{QueueManager}->isa("MQSeries::QueueManager") ) {
	    $self->{QueueManager} = $args{QueueManager};
	}
	else {
	    $self->{Carp}->("Invalid argument: 'QueueManager' must be an MQSeries::QueueManager object");
	    return;
	}
    }
    else {
	$self->{QueueManager} = MQSeries::QueueManager->new
	  (
	   QueueManager 		=> $args{QueueManager},
	   Carp 			=> $self->{Carp},
	  )	or return;
    }

    #
    # Sanity check the data conversion CODE snippets.
    #
    foreach my $key ( qw( PutConvert GetConvert ) ) {
	if ( $args{$key} ) {
	    if ( ref $args{$key} ne "CODE" ) {
		$self->{Carp}->("Invalid argument: '$key' must be a CODE reference");
		return;
	    }
	    else {
		$self->{$key} = $args{$key};
	    }
	}
	elsif ( ref $self->{QueueManager}->{$key} eq "CODE" ) {
	    # 'Inherit' them from the queue manager object
	    $self->{$key} = $self->{QueueManager}->{$key};
	}
    }

    #
    # We require (minimally) a Queue name
    #
    if ( $args{Queue} ) {
	$self->{Queue} = $args{Queue};
	if ( ref $args{Queue} eq "ARRAY" ) {
	    # Distribution list
	    $self->{ObjDescPtr}->{ObjectRecs} = $args{Queue};
	}
	else {
	    $self->{ObjDescPtr}->{ObjectName} = $args{Queue};
	}
    }
    else {
	$self->{Carp}->("Required argument 'Queue' not specified");
	return;
    }

    #
    # Optionally, if the Queue is a model queue, you'll want to
    # specify the Dynamic Queue name
    #
    if ( $args{DynamicQName} ) {
	$self->{ObjDescPtr}->{DynamicQName} = $args{DynamicQName};
    }

    #
    # You can also pass the close options, which will be used in the
    # Close() method, which is called upon object destruction.
    #
    if ( $args{CloseOptions} ) {
	$self->{CloseOptions} = $args{CloseOptions};
    }
    else {
	$self->{CloseOptions} = 0;
    }

    #
    # Maximum flexibility.  If you provide the ObjDesc, its a full
    # override, and you have to know what you are doing.
    #
    if ( exists $args{ObjDesc} ) {
	if ( ref $args{ObjDesc} eq "HASH" ) {
	    $self->{ObjDescPtr} = $args{ObjDesc};
	}
	else {
	    $self->{Carp}->("Invalid argument: 'ObjDesc' must be a HASH reference");
	    return;
	}
    }
    
    #
    # How are we opening this?  Only one of Options or Mode can be
    # specified.  Actually, cut people some slack here.  If NoAutoOpen
    # is used, then you might very well be passing Mode or Options to
    # the Open() method
    #
    unless ( $args{NoAutoOpen} ) {
	if (
	    ( exists $args{Options} and exists $args{Mode} )
	    or
	    ( not exists $args{Options} and not exists $args{Mode} )
	   ) {
	    $self->{Carp}->("Incompatible arguments: one and only one of 'Options' or 'Mode' must be given");
	    return;
	}
    }

    #
    # Optionally disable the automatic message buffer resizing
    #
    if ( $args{DisableAutoResize} ) {
	$self->{DisableAutoResize} = $args{DisableAutoResize};
    }
    
    #
    # If the options are given, we assume you know what you're doing.
    #
    if ( exists $args{Options} ) {
	$self->{Options} = $args{Options};
	# And, we'll let the MQI whine at you if you misuse it.
	$self->{GetEnable} = 1;
	$self->{PutEnable} = 1;
    }

    #
    # If the Mode is given, then we have a few defaults to choose from
    #
    if ( exists $args{Mode} ) {

	if ( $args{Mode} eq 'input' ) {
	    $self->{Options} |= MQOO_INPUT_AS_Q_DEF;
	    $self->{GetEnable} = 1;
	}
	elsif ( $args{Mode} eq 'input_exclusive' ) {
	    $self->{Options} |= MQOO_INPUT_EXCLUSIVE;
	    $self->{GetEnable} = 1;
	}
	elsif ( $args{Mode} eq 'input_shared' ) {
	    $self->{Options} |= MQOO_INPUT_SHARED;
	    $self->{GetEnable} = 1;
	}
	elsif ( $args{Mode} eq 'output' ) {
	    $self->{Options} |= MQOO_OUTPUT;
	    $self->{PutEnable} = 1;
	}
	else {
	    $self->{Carp}->("Invalid argument: 'Mode' value $args{Mode} not yet supported");
	    return;
	}
	
    }

    unless ( $args{NoAutoOpen} ) {
	my $result = $self->Open();
	foreach my $code ( qw(CompCode Reason) ) {
	    if ( ref $args{$code} eq "SCALAR" ) {
		${$args{$code}} = $self->{$code};
	    }
	}
	return unless $result;
    } 

    return $self;

}

sub CompCode {
    my $self = shift;
    return $self->{"CompCode"};
}

sub Reason {
    my $self = shift;
    return $self->{"Reason"};
}

sub Reasons {
    my $self = shift;
    return $self->{ObjDesc}->{ResponseRecs};
}

sub Close {

    my $self = shift;
    my (%args) = @_;

    return 1 unless $self->{Hobj};

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    if ( $args{Options} ) {
	$self->{CloseOptions} = $args{Options};
    }

    MQCLOSE(
	    $self->{QueueManager}->{Hconn},
	    $self->{Hobj},
	    $self->{CloseOptions},
	    $self->{"CompCode"},
	    $self->{"Reason"},
	   );
    if ( $self->{"CompCode"} == MQCC_OK ) {
	delete $self->{Hobj};
	return 1;
    }
    elsif ( $self->{"Reason"} == MQRC_HCONN_ERROR ) {
	delete $self->{Hobj};
	return 1;
    }
    else {
	$self->{Carp}->("MQCLOSE of $self->{ObjDescPtr}->{ObjectName} on " .
			qq/$self->{QueueManager}->{QueueManager} failed (Reason = $self->{"Reason"})/);
	return;
    }

}

sub DESTROY {
    my $self = shift;
    $self->Close();
}

#
# The real work is usually done with Put() and Get()
#
sub Put {

    my $self = shift;
    my %args = @_;

    return unless $self->Open();

    $self->{"CompCode"} 	= MQCC_FAILED;
    $self->{"Reason"} 		= MQRC_UNEXPECTED_ERROR;

    my $PutMsgOpts = 
      {
       Options			=> MQPMO_FAIL_IF_QUIESCING,
      };

    my $retrycount = 0;
    my $buffer = "";

    unless ( $self->{PutEnable} ) {
	$self->{Carp}->("Put() is disabled; Queue not opened for output");
	return;
    }

    unless ( ref $args{Message} and $args{Message}->isa("MQSeries::Message") )  {
	$self->{Carp}->("Invalid argument: 'Message' must be an MQSeries::Message object");
	return;
    }

    if ( $args{PutMsgOpts} ) {

	unless ( ref $args{PutMsgOpts} eq 'HASH' ) {
	    $self->{Carp}->("Invalid PutMsgOpts argument; must be a HASH reference");
	    return;
	}

	$PutMsgOpts = $args{PutMsgOpts};

    }
    else {

	if ( $args{PutMsgRecs} ) {
	    $PutMsgOpts->{PutMsgRecs} = $args{PutMsgRecs};
	}
	
	if ( $args{Sync} ) {
	    $PutMsgOpts->{Options} |= MQPMO_SYNCPOINT;
	}
	else {
	    $PutMsgOpts->{Options} |= MQPMO_NO_SYNCPOINT;
	}
	
    }

    if ( $args{PutConvert} ) {
	if ( ref $args{PutConvert} ne "CODE" ) {
	    $self->{Carp}->("Invalid argument: 'PutConvert' must be a CODE reference");
	    return;
	}
	else {
	    $buffer = $args{PutConvert}->($args{Message}->Data());
	}
    }
    else {
	if ( $args{Message}->can("PutConvert") ) {
	    $buffer = $args{Message}->PutConvert($args{Message}->Data());
	}
	elsif ( ref $self->{PutConvert} eq "CODE" ) {
	    $buffer = $self->{PutConvert}->($args{Message}->Data());
	}
	else {
	    $buffer = $args{Message}->Data();
	}
    }

    unless ( defined $buffer ) {
	$self->{Carp}->("Data conversion hook (PutConvert) failed");
	return;
    }

    MQPUT(
	  $self->{QueueManager}->{Hconn},
	  $self->{Hobj},
	  $args{Message}->MsgDesc(),
	  $PutMsgOpts,
	  $buffer,
	  $self->{"CompCode"},
	  $self->{"Reason"},
	 );

    if ( $self->{"CompCode"} == MQCC_OK ) {
	return 1;
    }
    elsif ( $self->{"CompCode"} == MQCC_WARNING ) {
	#
	# What do we do here?  These are 'partial' successes.
	#
	return -1;
    }
    else {
	$self->{Carp}->(qq/MQPUT failed (Reason = $self->{"Reason"})/);
	return;
    }

}

sub Get {

    my $self = shift;
    my %args = @_;

    return unless $self->Open();

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    my $GetMsgOpts = {};
    my $retrycount = 0;

    unless ( $self->{GetEnable} ) {
	$self->{Carp}->("Get() is disabled; Queue not opened for input");
	return;
    }

    unless ( ref $args{Message} and $args{Message}->isa("MQSeries::Message") )  {
	$self->{Carp}->("Invalid argument: 'Message' must be an MQSeries::Message object");
	return;
    }

    if ( $args{GetMsgOpts} ) {

	unless ( ref $args{GetMsgOpts} eq 'HASH' ) {
	    $self->{Carp}->("Invalid GetMsgOpts argument; must be a HASH reference");
	    return;
	}

	$GetMsgOpts = $args{GetMsgOpts};

    }
    else {

	$GetMsgOpts = { Options => MQGMO_FAIL_IF_QUIESCING | MQGMO_CONVERT };

	if ( $args{Sync} ) {
	    $GetMsgOpts->{Options} |= MQGMO_SYNCPOINT;
	}

	if ( exists $args{Wait} ) {
	    if ( $args{Wait} == 0 ) {
		$GetMsgOpts->{Options} |= MQGMO_NO_WAIT;
	    }
	    elsif ( $args{Wait} == -1 ) {
		$GetMsgOpts->{Options} |= MQGMO_WAIT;
		$GetMsgOpts->{WaitInterval} = MQWI_UNLIMITED;
	    }
	    else {
		$GetMsgOpts->{Options} |= MQGMO_WAIT;
		$GetMsgOpts->{WaitInterval} = $args{Wait};
	    }
	}
	else {
	    $GetMsgOpts->{Options} |= MQGMO_NO_WAIT;
	}

    }

    if ( $args{GetConvert} && ref $args{GetConvert} ne "CODE" ) {
	$self->{Carp}->("Invalid argument: 'GetConvert' must be a CODE reference");
	return;
    }

    #
    # This flag is used to prevent the redo logic from looping.  We
    # want to handle MQRC_TRUNCATED_MSG_FAILED and
    # MQRC_CONVERTED_MSG_TOO_BIG retries exactly once.
    #
    # If DisableAutoResize is given as either an argument to the
    # object constructor, *or* to the Get method call, then this will
    # effectively disable the redo logic.
    #
    my $redone = $self->{DisableAutoResize} || $args{DisableAutoResize};

  GET:
    {
	my $data = undef;
	my $datalength = $args{Message}->BufferLength();

	my $buffer = MQGET(
			   $self->{QueueManager}->{Hconn},
			   $self->{Hobj},
			   $args{Message}->MsgDesc(),
			   $GetMsgOpts,
			   $datalength,
			   $self->{"CompCode"},
			   $self->{"Reason"},
			  );

	#
	# We attempt the data conversion hook if we accepted a
	# truncated message.  Note that it may very well fail, but
	# we'll try anyway.
	#
	if (
	    $self->{"CompCode"} == MQCC_OK ||
	    (
	     $self->{"CompCode"} == MQCC_WARNING &&
	     $self->{"Reason"} == MQRC_TRUNCATED_MSG_ACCEPTED
	    )
	   ) {

	    if ( $args{GetConvert} ) {
		$data = $args{GetConvert}->($buffer);
	    }
	    else {
		if ( $args{Message}->can("GetConvert") ) {
		    $data = $args{Message}->GetConvert($buffer);
		}
		elsif ( ref $self->{GetConvert} eq "CODE" ) {
		    $data = $self->{GetConvert}->($buffer);
		}
		else {
		    $data = $buffer;
		}
	    }

	    unless ( defined $data ) {
		$self->{Carp}->("Data conversion hook (GetConvert) failed");
		return;
	    }

	    $args{Message}->Data($data);
	    return 1;

	}
	elsif ( $self->{"CompCode"} == MQCC_WARNING ) {

	    if ( $self->{"Reason"} == MQRC_TRUNCATED_MSG_FAILED and not $redone ) {
		$args{Message}->BufferLength($datalength);
		$redone = 1;
		redo GET;
	    }
	    elsif ( $self->{"Reason"} == MQRC_CONVERTED_MSG_TOO_BIG and not $redone ) {
		$args{Message}->BufferLength(2 * $datalength);
		$redone = 1;
		redo GET;
	    }
	    else {
		$self->{Carp}->(qq/MQGET failed (Reason = $self->{"Reason"})/);
		return;
	    }
	    
	}
	else {

	    if ( $self->{"Reason"} == MQRC_NO_MSG_AVAILABLE ) {
		#
		# XXX -- How do we determine this in the client API???
		#
		return -1;
	    }
	    else {
		$self->{Carp}->(qq/MQGET failed (Reason = $self->{"Reason"})/);
		return;
	    }

	}

    }

}

sub Backout {

    my $self = shift;
    return unless $self->Open();

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    MQBACK(
	   $self->{QueueManager}->{Hconn},
	   $self->{"CompCode"},
	   $self->{"Reason"},
	  );
    if ( $self->{"CompCode"} == MQCC_OK ) {
	return 1;
    }
    else {
	$self->{Carp}->(qq/MQBACK failed (Reason = $self->{"Reason"})/);
	return;
    }

}

sub Commit {

    my $self = shift;
    return unless $self->Open();

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    MQCMIT(
	   $self->{QueueManager}->{Hconn},
	   $self->{"CompCode"},
	   $self->{"Reason"},
	  );
    if ( $self->{"CompCode"} == MQCC_OK ) {
	return 1;
    }
    else {
	$self->{Carp}->(qq/MQCMIT failed (Reason = $self->{"Reason"})/);
	return;
    }

}

sub Inquire {

    my $self = shift;
    my (@args) = @_;

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    my (@keys) = ();

    my $RequestValues = \%MQSeries::Command::PCF::RequestValues;
    my $ResponseParameters = \%MQSeries::Command::PCF::ResponseParameters;
    
    foreach my $key ( @args ) {

	unless ( exists $RequestValues->{Queue}->{$key} ) {
	    $self->{Carp}->("Unrecognized Queue attribute: '$key'");
	    return;
	}

	push(@keys,$RequestValues->{Queue}->{$key});

    }

    my (@values) = MQINQ(
			 $self->{QueueManager}->{Hconn},
			 $self->{Hobj},
			 $self->{"CompCode"},
			 $self->{"Reason"},
			 @keys,
			);

    unless ( $self->{"CompCode"} == MQCC_OK && $self->{"Reason"} == MQRC_NONE ) {
	$self->{Carp}->("MQINQ call failed. " .
			qq(CompCode => '$self->{"CompCode"}', ) . 
			qq(Reason => '$self->{"Reason"}'\n));
	return;
    }

    # In case the data parsing fails...
    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    my (%values) = ();

    for ( my $index = 0 ; $index <= $#keys ; $index++ ) {
	
	my ($key,$value) = ($keys[$index],$values[$index]);

	my ($newkey,$ResponseValues) = @{$ResponseParameters->{Queue}->{$key}};

	if ( $ResponseValues ) {
	    unless ( exists $ResponseValues->{$value} ) {
		$self->{Carp}->("Unrecognized value '$value' for key '$newkey'\n");
		return;
	    }
	    $values{$newkey} = $ResponseValues->{$value};
	}
	else {
	    $values{$newkey} = $value;
	}

    }

    $self->{"CompCode"} = MQCC_OK;
    $self->{"Reason"} = MQRC_NONE;

    return %values;

}

sub Set {

    my $self = shift;
    my (%args) = @_;

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    my (%keys) = ();

    my $RequestValues = \%MQSeries::Command::PCF::RequestValues;
    
    foreach my $key ( keys %args ) {

	my $value = $args{$key};

	unless ( exists $RequestValues->{Queue}->{$key} ) {
	    $self->{Carp}->("Unrecognized Queue attribute: '$key'");
	    return;
	}

	my $newkey = $RequestValues->{Queue}->{$key};

	if ( exists $RequestValues->{$key} ) {
	    unless ( exists $RequestValues->{$key}->{$value} ) {
		$self->{Carp}->("Unrecognized Queue attribute value '$value' for key '$key'\n");
		return;
	    }
	    $keys{$newkey} = $RequestValues->{$key}->{$value};
	}
	else {
	    $keys{$newkey} = $value;
	}

    }

    MQSET(
	  $self->{QueueManager}->{Hconn},
	  $self->{Hobj},
	  $self->{"CompCode"},
	  $self->{"Reason"},
	  %keys,
	 );

    unless ( $self->{"CompCode"} == MQCC_OK && $self->{"Reason"} == MQRC_NONE ) {
	$self->{Carp}->("MQSET call failed. " .
			qq/CompCode => '$self->{"CompCode"}', / . 
			qq/Reason => '$self->{"Reason"}'\n/);
	return;
    }

    return 1;

}

#
# Unlike *most* of these methods (here, and in most other code), this
# returns a hard reference to the entire hash
#
sub ObjDesc {

    my $self = shift;

    if ( $_[0] ) {
	if ( exists $self->{ObjDescPtr}->{$_[0]} ) {
	    return $self->{ObjDescPtr}->{$_[0]};
	}
	else {
	    $self->{Carp}->("No such ObjDescPtr field: $_[0]");
	    return;
	}
    }
    else {
	return $self->{ObjDescPtr};
    }

}

sub Open {

    my $self = shift;
    my %args = @_;

    return 1 if $self->{Hobj};

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    if ( exists $args{Options} and exists $args{Mode} ) {
	$self->{Carp}->("Incompatible arguments: one and only one of 'Options' or 'Mode' must be given");
	return;
    }

    #
    # If the options are given, we assume you know what you're doing.
    #
    if ( exists $args{Options} ) {
	$self->{Options} = $args{Options};
	# And, we'll let the MQI whine at you if you misuse it.
	$self->{GetEnable} = 1;
	$self->{PutEnable} = 1;
    }

    #
    # If the Mode is given, then we have a few defaults to choose from
    #
    if ( exists $args{Mode} ) {

	if ( $args{Mode} eq 'input' ) {
	    $self->{Options} |= MQOO_INPUT_AS_Q_DEF;
	    $self->{GetEnable} = 1;
	}
	elsif ( $args{Mode} eq 'input_exclusive' ) {
	    $self->{Options} |= MQOO_INPUT_EXCLUSIVE;
	    $self->{GetEnable} = 1;
	}
	elsif ( $args{Mode} eq 'input_shared' ) {
	    $self->{Options} |= MQOO_INPUT_SHARED;
	    $self->{GetEnable} = 1;
	}
	elsif ( $args{Mode} eq 'output' ) {
	    $self->{Options} |= MQOO_OUTPUT;
	    $self->{PutEnable} = 1;
	}
	else {
	    $self->{Carp}->("Invalid argument: 'Mode' value $args{Mode} not yet supported");
	    return;
	}
	
    }

    #
    # Open the Queue
    #
    $self->{Hobj} = MQOPEN(
			   $self->{QueueManager}->{Hconn},
			   $self->{ObjDescPtr},
			   $self->{Options},
			   $self->{"CompCode"},
			   $self->{"Reason"},
			  );

    if ( $self->{"CompCode"} == MQCC_OK ) {
	return 1;
    }
    elsif ( $self->{"CompCode"} == MQCC_WARNING ) {
	# This is when Reason == MQRC_MULTIPLE_REASONS
	return -1;
    }
    elsif ( $self->{"CompCode"} == MQCC_FAILED ) {
	$self->{Carp}->(qq/MQOPEN failed (Reason = $self->{"Reason"})/);
	return;
    }
    else {
	$self->{Carp}->(qq/MQOPEN failed, unrecognized CompCode: '$self->{"CompCode"}'/);
	return;
    }

}

1;

__END__

=head1 NAME

MQSeries::Queue -- OO interface to the MQSeries Queue objects

=head1 SYNOPSIS

  use MQSeries;
  use MQSeries::Queue;
  use MQSeries::Message;

  #
  # Open a queue for output, loop getting messages, updating some
  # database with the data.
  # 
  my $queue = MQSeries::Queue->new
    (
     QueueManager 	=> 'some.queue.manager',
     Queue 		=> 'SOME.QUEUE',
     Mode 		=> 'input_exclusive',
    )
    or die("Unable to open queue.\n");

  while ( 1 ) {

    my $getmessage = MQSeries::Message->new;

    $queue->Get
      (
       Message => $getmessage,
       Sync => 1,
      ) or die("Unable to get message\n" .
	       "CompCode = " . $queue->CompCode() . "\n" .
	       "Reason = " . $queue->Reason() . "\n");

    if ( UpdateSomeDatabase($getmessage->Data()) ) {
        $queue->Commit()
	  or die("Unable to commit changes to queue.\n" .
		 "CompCode = " . $queue->CompCode() . "\n" .
		 "Reason = " . $queue->Reason() . "\n");
    }
    else {
        $queue->Backout()
	  or die("Unable to backout changes to queue.\n" .
		 "CompCode = " . $queue->CompCode() . "\n" .
		 "Reason = " . $queue->Reason() . "\n");
    }

  }

  #
  # Put a message into the queue, using Storable to allow use of
  # references as message data. (NOTE: this is done for you if use the
  # MQSeries::Message::Storable class.)
  #
  use Storable;
  my $queue = MQSeries::Queue->new
    (
     QueueManager 	=> 'some.queue.manager',
     Queue 		=> 'SOME.QUEUE',
     Mode 		=> 'output',
     PutConvert        	=> \&Storable::nfreeze,
     GetConvert 	=> \&Storable::thaw,
    )
    or die("Unable to open queue.\n");

  my $putmessage = MQSeries::Message->new
    (
     Data => {
	      a => [qw( b c d )],
	      e => {
		    f => "Huh?",
		    g => "Wow!",
		   },
	      h => 42,
	     },
    );

  $queue->Put( Message => $putmessage )
    or die("Unable to put message onto queue.\n" .
	   "CompCode = " . $queue->CompCode() . "\n" .
	   "Reason = " . $queue->Reason() . "\n");

  #
  # Alternate mechanism for specifying the conversion routines.
  #
  my $queue = MQSeries::Queue->new
    (
     QueueManager 	=> 'some.queue.manager',
     Queue 		=> 'SOME.QUEUE',
     Mode 		=> 'output',
    )
    or die("Unable to open queue.\n");

  my $putmessage = MQSeries::Message->new
    (
     Data => {
	      a => [qw( b c d )],
	      e => {
		    f => "Huh?",
		    g => "Wow!",
		   },
	      h => 42,
	     },
    );

  $queue->Put(
	      Message => $putmessage
  	      PutConvert => \&Storable::freeze,
	     )
    or die("Unable to put message onto queue.\n" .
	   "CompCode = " . $queue->CompCode() . "\n" .
	   "Reason = " . $queue->Reason() . "\n");

=head1 DESCRIPTION

The MQSeries::Queue object is an OO mechanism for opening MQSeries
Queues, and putting and getting messages from those queues, with an
interface which is much simpler than the full MQI.

This module is used together with MQSeries::QueueManager and
MQSeries::Message.  These objects provide a subset of the MQI, with a
simpler interface.

The primary value added by this interface is logic to retry the
connection under certain failure conditions.  Basically, any Reason
Code which represents a transient condition, such as a Queue Manager
shutting down, or a connection lost (possible due to a network
glitch?), will result in the MQCONN call being retried, after a short
sleep.  See below for how to tune this behavior.

This is intended to allow developers to write MQSeries applications
which recover from short term outages without intervention.  This
behavior is critically important to the authors applications, but may
not be right for yours.  

=head1 METHODS

=head2 new

The arguments to the constructor are a hash, with the following
key/value pairs (required keys are marked with a '*'):

  Key                		Value
  ===                		=====
  QueueManager      		String, or MQSeries::QueueManager object
  Queue*             		String, or ARRAY reference (distribution list)
  Mode*              		String
  Options*           		MQOPEN 'Options' values
  CloseOptions	     		MQCLOSE 'Options' values
  DisableAutoResize  		Boolean
  NoAutoOpen    		Boolean
  ObjDesc            		HASH Reference
  Carp               		CODE Reference
  PutConvert         		CODE Reference
  GetConvert         		CODE Reference
  CompCode           		Reference to Scalar Variable
  Reason             		Reference to Scalar Variable

NOTE: Only B<one> or the 'Options' or 'Mode' keys can be specified.
They are mutually exclusive.  If 'NoAutoOpen' is given, then both
'Options' and 'Mode' are optional, as they canbe passed directly to
the Open() method.

=over 4

=item QueueManager

The Queue Manager to connect to must be specified, unless you want to
connect to the "default" queue manager, and your site supports such a
configuration.  

This can either be an MQSeries::QueueManager object, or the name of
the Queue Manager.  Since the MQSeries::Queue object will internally
create the MQSeries::QueueManager object, if given a name, this is the
simpler mechanism.

Code which opens multiple Queues on a single Queue Manager can be
slightly optimized by creating the QueueManager object explicitly, and
then reusing it for the multiple MQSeries::Queue objects which must be
instantiated.  This will avoid a few unnecesary MQCONN calls, but this
overhead should prove to be minimal in most cases.

If the "default" queue manager is to be used, then the QueueManager
argument can either be specified as the empty string "", or just
omitted entirely.

=item Queue

The name of the Queue obviously must be specified.  This can be either
a plain ASCII string, indicating a single queue, or an ARRAY
reference, indicating a distribution list.  There are three ways to
specify the list.

The list may be a simple array of strings:

  $queue = MQSeries::Queue->new
    (
     QueueManager 	=> "FOO",
     Queue 		=> [qw( QUEUE1 QUEUE2 QUEUE3 )],
    )

or, it can be an array of arrays, each one specifying the queue and
queue manager name of the target queue:

  $queue = MQSeries::Queue->new
    (
     QueueManager 	=> "FOO",
     Queue 		=> [
			    [qw( QUEUE1 QM1 )],
			    [qw( QUEUE2 QM2 )],
			    [qw( QUEUE3 QM3 )],
			   ],
    )

or finally, it can be an array of hash references, each naming the
queue and queue manager:

  $queue = MQSeries::Queue->new
    (
     QueueManager 	=> "FOO",
     Queue 		=> 
     [
      {
       ObjectName	=> 'QUEUE1',
       ObjectQMgrName	=> 'QM1',
      },
      {
       ObjectName	=> 'QUEUE2',
       ObjectQMgrName	=> 'QM2',
      },
      {
       ObjectName	=> 'QUEUE3',
       ObjectQMgrName	=> 'QM3',
      },
     ],
    )

In the latter two cases, the queue manager names are optional.  Which
method to use is largely a choice of style.

=item Mode

If the B<Mode> key is specified, then the B<Options> key may B<NOT> be
specified.  These are mutually exclusive.

The B<Mode> is a shorthand for opening the Queue for output or input,
without requiring the developer to work with the Options flags
directly.  The mode may have one of the following values, which
implies the Options shown.

  Mode Value       Equivalent MQOPEN Options
  ==========       =========================
  input            MQOO_INPUT_AS_Q_DEF | MQOO_FAIL_IF_QUIESCING
  input_shared     MQOO_INPUT_SHARED | MQOO_FAIL_IF_QUIESCING
  input_exclusive  MQOO_INPUT_EXCLUSIVE | MQOO_FAIL_IF_QUIESCING
  output           MQOO_OUTPUT | MQOO_FAIL_IF_QUIESCING

=item Options

If the B<Options> key is specified, then the B<Mode> key may B<NOT> be
specified.  These are mutually exclusive.  This is a used as-is as the
Options field in the MQOPEN call.  Refer to the MQI documentation on
MQOPEN() for more details.

=item DisableAutoResize

This is a Boolean value, which if true, will disable the automatic
resizing of the message buffer when it is either truncated, or the
converted message will not fit.

See the Get() method documentation for more information.

=item NoAutoOpen

This will disable the implicit call to the Open() method by the
constructor, thus requiring the application to call it itself.  This
allows for more fine-grained error checking, since the constructur
will then fail only if there is a problem parsing the constructor
arguments.  The subsequent call to Open() can be error checked
independently of the new() constructor.

=item ObjDesc

The value of this key is a hash refernece which sets the key/values of
the MsgDesc structure.  See the "MQSeries Application Programming
Reference" documentation for the possible keys and values of the MQOD
structure.

Also, see the examples section for specific usage of this feature.
This is one area of the API which is not easily hidden; you have to
know what you are doing.

=item Carp

This key specifies a code reference to a routine to replace all of the
carp() calls in the API, allowing the user of the API to trap and
handle all of the error message generated internally, or simply
redirect how they get logged.

For example, one might want everything to be logged via syslog:

  sub MyLogger {
      my $message = @_;
      foreach my $line ( split(/\n+/,$message) ) {
          syslog("err",$message);
      }
  }

Then, one tells the object to use this routine:

  my $queue = MQSeries::Queue->new
    (
     QueueManager 	=> 'some.queue.manager',
     Queue 		=> 'SOME.QUEUE',
     Carp 		=> \&MyLogger,
    ) or die("Unable to connect to queue manager.\n");

The default, as one might guess, is Carp::carp();

=item PutConvert, GetConvert

These are CODE references to subroutines which are used to convert the
data in a MQSeries::Message object prior to passing it to the MQPUT
MQI call, or convert the data retreived from the queue by the MQGET
MQI call before inserting it into a MQSeries::Message object.

See the MQSeries::QueueManager documentation for details on the
calling and error handling syntax of these subroutines, as well as an
example using Storable.pm to pass perl references around in MQSeries
messages.

If this key is not specified, then the MQSeries::Queue objects will
inherit these CODE references from the MQSeries::QueueManager object.
If the QueueManager key was given as a name, and not an object, then
no conversion is performed.

Note that these can be overridden for individual Put() or Get() calls,
if necessary for a single message, just as PutConvert can be
overridden for a single Put1() call (see MQSeries::QueueManager docs).

Also, note that to disable these for a single message, or a single
queue, one would simply pass a function that returns its first
argument.

  PutConvert => sub { return $_[0]; },
  GetConvert => sub { return $_[0]; },

See also the section "CONVERSION PRECEDENCE" in the
MQSeries::QueueManager documentation.

=item CompCode, Reason

WARNING: These keys are deprecated, and their use no longer
encouraged.  They are left in place only for backwards compabitility.

See the docs for the NoAutoOpen argument, and the Open() method.

When the constructor encounters an error, it returns nothing, and you
can not make method calls off of a non-existent object.  Thus, you do
not have access to the CompCode() and Reason() method calls.  If you
want to extract these values, you will have to pass a scalar reference
value to the constructor, for example:

  my $CompCode = MQCC_FAILED;
  my $Reason = MQRC_UNEXPECTED_ERROR;

  my $queue = MQSeries::Queue->new
    (
     QueueManager		=> 'some.queue.manager',
     Queue			=> 'SOME,QUEUE',
     CompCode			=> \$CompCode,
     Reason			=> \$Reason,
    ) || die "Unable to open queue: CompCode => $CompCode, Reason => $Reason\n";

But, this is ugly (authors opinion, but then, he gets to write the
docs, too).  

NOTE: If you let the MQSeries::Queue object implicitly create the
MQSeries::QueueManager object, and that fails, you will B<NOT> get the
CompCode/Reason values which resulted.  This is intentional.  If you
want this level of granularity, then instantiante the
MQSeries::QueueManager object yourself, and pass it to the
MQSeries::Queue constructor.

See the ERROR HANDLING section as well.

=back

=head2 Open

This method will accept the same Options and Mode arguments which can
be passed to the constructor (new()), and it merely calls MQOPEN() to
open the actual queue object.  

This method is called automatically by the constructor, unless the
NoAutoOpen argument is given.

Note that this is a new method as of the 1.06 release, and is provided
to enable more fine grained error checking.  See the ERROR HANDLING
section.

=head2 Close

The arguments to this method are a hash of key/value pairs, and
currently only one key is supported: "Options".  The value is the
Options argument to MQCLOSE().  This will override the "CloseOptions"
passed to the constructor.  This method merely calls MQCLOSE() to
close the actual queue object.

It is important to note that normally, this method need not be called,
since it is implicitly called via the object destructor.  If the
Close() call errors need to be handled, then it can be done
explicitly.  See the ERROR HANDLING section.

=head2 Put

This method wraps the MQPUT call.  The arguments are a hash, with the
following key/value pairs (required keys are marked with a '*'):

  Key         Value
  ===         =====
  Message*    MQSeries::Message object
  PutMsgOpts  HASH Reference
  PutMsgRecs  ARRAY Reference
  Sync        Boolean
  PutConvert  CODE Reference

=over 4

=item Message

This argument is the message to be placed onto the queue.  The value
must be an MQSeries::Message object.

=item PutMsgOpts

This option allows the programmer complete control over the PutMsgOpts
structure passed to the MQPUT() call.  If this option is specified,
then the Sync option is simply ignored.

The default options specified by the OO API are

  MQGMO_FAIL_IF_QUIESCING

See the MQPUT() documentation for the use of PutMsgOpts.  

=item PutMsgRecs

This argument is relevant only when using distribution lists.

The value is an ARRAY reference, specifying the put message records
for the individual queues in the distribution list.  Normally, these
are specified as part of the PutMsgOpts, but this API attempts to hide
the complexity of the PutMsgOpts structure from the user.

When using distribution lists, PutMsgRecs are often necessary to
control how the MsgId, CorrelId, and three other specific fields in
the MsgDesc are handled.

For details, see the MQPUT() and MQPUT1() documentation in
MQSeries(3).

=item Sync

This is a flag to indicate that the Syncpoint option is to be used,
and the message(s) not committed to the queue until an MQBACK or
MQCOMM call is made.  These are both wrapped with the Backout() and
Commit() methods respectively.

The value is simply interpreted as true or false.

=item PutConvert

This is a means of overriding the PutConvert routine specified for the
MQSeries::Queue object, for a single Put.  See the new() documentation
for more details.

=back

=head2 Get

This method wraps the MQGET call.  The arguments are a hash, with the
following key/value pairs (required keys are marked with a '*'):

    Key                Value
    ===                =====
    Message*           MQSeries::Message object
    GetMsgOpts         HASH Reference
    Wait               Numeric Value
    Sync               Boolean
    DisableAutoResize  Boolean
    GetConvert         CODE Reference

The return value of Get() is either 1, 0 or -1.  Success or failure
can still be interpreted in a Boolean context, with the following
caveat.  A value of 1 is returned when a message was successfully
retreives from the queue.  A value of 0 is returned if some form of
error was encountered.  A value of -1 is returned when no message was
retreived, but the MQGET call failed with a Reason Code of
"MQRC_NO_MSG_AVAILABLE".

The last condition (-1) may or may not be an error, depending on your
application.  This merely indicates that a message matching the
specified MsgDesc criteria was not found, or perhaps the queue was
just empty.  You have to decide how to handle this.

By default, the Get() method will also handle the message buffer size
being too small for two very specific cases.

Case 1:  Reason == MQRC_TRUNCATED_MSG_FAILED

In this case, the BufferLength of the Message object is reset to the
DataLength value returned by the MQGET() call, and the MQGET() call is
redone.

Case 2:  Reason == MQRC_CONVERTED_MSG_TOO_BIG

In this case, the BufferLength of the Message object is reset to
B<twice> the DataLength value returned by the MQGET() call, and the
MQGET() call is redone.  Doubling the size is probably overkill, but
there is no deterministic way of finding the actual size required.
Since most of the conversions are character set mappings, we are
assuming that double will always be sufficient.

Note that this functionality can be disabled, if not desired, by
specifying DisableAutoResize as an argument to either the
MQSeries::Queue->new() constructor or the Get() method.

=over 4

=item Message

This argument is the MQSeries::Message object into which the message
extracted from the queue is placed.  This can be a 'raw'
MQSeries::Message, or it can be one with the MsgId, or some other key
in the MsgDesc explicitly specified, in order to retreive a specific
message.  See MQSeries::Message documentation for more details.

=item GetMsgOpts

This option allows the programmer complete control over the GetMsgOpts
structure passed to the MQGET() call.  If this option is specified,
then the Sync, and Wait options are simply ignored.

The default options specified by the OO API are

  MQGMO_FAIL_IF_QUIESCING
  MQGMO_CONVERT

See the MQGET() documentation for the use of GetMsgOpts.  

=item Wait

This is a numeric value, interpreted as follows.  If the value is
greater than zero, then the MQGMO_WAIT option is used, and the value
is set as the WaitInterval in the GetMsgOpts structure.

Remember, this value is interpreted by the API as a number of
milliseconds, not seconds (the rest of the OO-API uses seconds).

If the value is 0, then the MQGMO_NO_WAIT option is used.

If the value is -1, then the MQGMO_WAIT option is used, and the
WaitInterval is set to MQWI_UNLIMITED, meaning the MQGET call will
block until a message appears on the queue.

The default is 0, the same as the MQGET() call itself.

NOTE: MQWI_UNLIMITED should be used with caution, as applications
which block forever can prevent queue managers from shutting down
elegantly, in some cases.

=item Sync

This is a flag to indicate that the Syncpoint option is to be used,
and the message(s) not committed to the queue until an MQBACK or
MQCMIT call is made.  These are both wrapped with the Backout() and
Commit() methods respectively.

The value is simply interpreted as true or false.

=item DisableAutoResize

This is a Boolean value, which if true, will disable the automatic
resizing of the message buffer when it is either truncated, or the
converted message will not fit.

=item GetConvert

This is a means of overriding the GetConvert routine specified for the
MQSeries::Queue object, for a single Get.  See the new() documentation
for more details.

=back

=head2 Inquire

This method is an interface to the MQINQ() API call, however, it takes
more convenient, human-readable strings in place of the C macros for
the selectors, as well as supports more readable strings for some of
the data values as well.

For example, to query the MaxMsgLength and MaxQDepth of a queue:

  my %qattr = $queue->Inquire( qw(MaxMsgLength MaxQDepth) );

The argument to this method is a list of "selectors", or Queue
attributes, to be queried.  The following table shows the complete set
of possible keys, and their underlying C macro.  

Note that this list is all-inclusive, and that many of these are not
supported on some of the MQSeries platforms.  Consult the IBM
documentation for such details.

    Key				Macro
    ===				=====
    AlterationDate              MQCA_ALTERATION_DATE
    AlterationTime              MQCA_ALTERATION_TIME
    BackoutRequeueName          MQCA_BACKOUT_REQ_Q_NAME
    BackoutThreshold            MQIA_BACKOUT_THRESHOLD
    BaseQName                   MQCA_BASE_Q_NAME
    ClusterDate                 MQCA_CLUSTER_DATE
    ClusterName                 MQCA_CLUSTER_NAME
    ClusterNamelist             MQCA_CLUSTER_NAMELIST
    ClusterQType                MQIA_CLUSTER_Q_TYPE
    ClusterTime                 MQCA_CLUSTER_TIME
    CreationDate                MQCA_CREATION_DATE
    CreationTime                MQCA_CREATION_TIME
    CurrentQDepth               MQIA_CURRENT_Q_DEPTH
    DefBind                     MQIA_DEF_BIND
    DefInputOpenOption          MQIA_DEF_INPUT_OPEN_OPTION
    DefPersistence              MQIA_DEF_PERSISTENCE
    DefPriority                 MQIA_DEF_PRIORITY
    DefinitionType              MQIA_DEFINITION_TYPE
    DistLists                   MQIA_DIST_LISTS
    HardenGetBackout            MQIA_HARDEN_GET_BACKOUT
    HighQDepth                  MQIA_HIGH_Q_DEPTH
    InhibitGet                  MQIA_INHIBIT_GET
    InhibitPut                  MQIA_INHIBIT_PUT
    InitiationQName             MQCA_INITIATION_Q_NAME
    MaxMsgLength                MQIA_MAX_MSG_LENGTH
    MaxQDepth                   MQIA_MAX_Q_DEPTH
    MsgDeliverySequence         MQIA_MSG_DELIVERY_SEQUENCE
    MsgDeqCount                 MQIA_MSG_DEQ_COUNT
    MsgEnqCount                 MQIA_MSG_ENQ_COUNT
    OpenInputCount              MQIA_OPEN_INPUT_COUNT
    OpenOutputCount             MQIA_OPEN_OUTPUT_COUNT
    ProcessName                 MQCA_PROCESS_NAME
    QDepthHighEvent             MQIA_Q_DEPTH_HIGH_EVENT
    QDepthHighLimit             MQIA_Q_DEPTH_HIGH_LIMIT
    QDepthLowEvent              MQIA_Q_DEPTH_LOW_EVENT
    QDepthLowLimit              MQIA_Q_DEPTH_LOW_LIMIT
    QDepthMaxEvent              MQIA_Q_DEPTH_MAX_EVENT
    QDesc                       MQCA_Q_DESC
    QMgrIdentifier              MQCA_Q_MGR_IDENTIFIER
    QMgrName                    MQCA_CLUSTER_Q_MGR_NAME
    QName                       MQCA_Q_NAME
    QNames                      MQCACF_Q_NAMES
    QServiceInterval            MQIA_Q_SERVICE_INTERVAL
    QServiceIntervalEvent       MQIA_Q_SERVICE_INTERVAL_EVENT
    QType                       MQIA_Q_TYPE
    RemoteQMgrName              MQCA_REMOTE_Q_MGR_NAME
    RemoteQName                 MQCA_REMOTE_Q_NAME
    RetentionInterval           MQIA_RETENTION_INTERVAL
    Scope                       MQIA_SCOPE
    Shareability                MQIA_SHAREABILITY
    TimeSinceReset              MQIA_TIME_SINCE_RESET
    TriggerControl              MQIA_TRIGGER_CONTROL
    TriggerData                 MQCA_TRIGGER_DATA
    TriggerDepth                MQIA_TRIGGER_DEPTH
    TriggerMsgPriority          MQIA_TRIGGER_MSG_PRIORITY
    TriggerType                 MQIA_TRIGGER_TYPE
    Usage                       MQIA_USAGE
    XmitQName                   MQCA_XMIT_Q_NAME

The return value of this method is a hash, whose keys are those given
as arguments, and whose values are the queried queue attributes.  In
most cases, the values are left unmolested, but in the following
cases, the values are mapped to more readable strings.

=over 4

=item DefBind  			(integer)  

    Key				Macro
    ===				=====
    OnOpen                      MQBND_BIND_ON_OPEN
    NotFixed                    MQBND_BIND_NOT_FIXED

=item DefinitionType		(integer)

    Key				Macro
    ===				=====
    Permanent                   MQQDT_PERMANENT_DYNAMIC
    Temporary                   MQQDT_TEMPORARY_DYNAMIC

=item DefInputOpenOption    	(integer)  

    Key				Macro
    ===				=====
    Exclusive                   MQOO_INPUT_EXCLUSIVE
    Shared                      MQOO_INPUT_SHARED

=item MsgDeliverySequence    	(integer)  

    Key				Macro
    ===				=====
    FIFO                        MQMDS_FIFO
    Priority                    MQMDS_PRIORITY

=item QServiceIntervalEvent    	(integer)  

    Key				Macro
    ===				=====
    High                        MQQSIE_HIGH
    None                        MQQSIE_NONE
    OK                          MQQSIE_OK

=item QType    			(integer)  

    Key				Macro
    ===				=====
    Alias                       MQQT_ALIAS
    All                         MQQT_ALL
    Cluster                     MQQT_CLUSTER
    Local                       MQQT_LOCAL
    Model                       MQQT_MODEL
    Remote                      MQQT_REMOTE

=item Scope    			(integer)  

    Key				Macro
    ===				=====
    Cell                        MQSCO_CELL
    QMgr                        MQSCO_Q_MGR

=item TriggerType    		(integer)  

    Key				Macro
    ===				=====
    Depth                       MQTT_DEPTH
    Every                       MQTT_EVERY
    First                       MQTT_FIRST
    None                        MQTT_NONE

=item Usage    			(integer)  

    Key				Macro
    ===				=====
    Normal                      MQUS_NORMAL
    XMITQ                       MQUS_TRANSMISSION

=back

=head2 Set

This method is an interface to the MQSET() API call, and like
Inquire(), it takes more convenient, human-readable strings in place
of the C macros.  

For example, to put inhibit a queue:

  $queue->Set( InhibitPut => 1 );

The argument to this method is a hash of key/value pairs representing
queue attributes to be set.  The MQSET() API supports setting a very
limited subset of specific queue attributes.  The following table
shows the complete set of possible keys, and their underlying C macros.

    Key				Macro
    ===				=====
    InhibitGet                  MQIA_INHIBIT_GET
    InhibitPut                  MQIA_INHIBIT_PUT
    DistLists                   MQIA_DIST_LISTS
    TriggerControl              MQIA_TRIGGER_CONTROL
    TriggerData                 MQCA_TRIGGER_DATA
    TriggerDepth                MQIA_TRIGGER_DEPTH
    TriggerMsgPriority          MQIA_TRIGGER_MSG_PRIORITY
    TriggerType                 MQIA_TRIGGER_TYPE

In addition, the data value for the "TriggerType" key can have one of
the following values:

    Key				Macro
    ===				=====
    Depth                       MQTT_DEPTH
    Every                       MQTT_EVERY
    First                       MQTT_FIRST
    None                        MQTT_NONE

All of the other values are simply Boolean (0 or 1), with the
exception of "TriggerData", which is a string.

This method call returns true upon success, and false upon failure.
CompCode() and Reason() will be set appropriately.

=head2 ObjDesc

This method can be used to query the ObjDesc data structure.  If no
argument is given, then the ObjDesc hash reference is returned.  If a
single argument is given, then this is interpreted as a specific key,
and the value of that key in the ObjDesc hash is returned.

=head2 Backout

This method takes no arguments, and merely calls MQBACK.  It returns
true on success, and false on failure.

NOTE: This operation is in reality not specific to the Queue, but
rather to the Queue Manager connection.  Because the API does not
require the developer to specifically open a Queue Manager connection
(via an MQSeries::QueueManager object), but will do so implicitly (see
the new() documentation above), these methods are provided as part of
the MQSeries::Queue API.  Note, however, that this does B<NOT> imply
that syncpoint operations can be performed at the individual Queue
level.  Transactions are still per-queue manager connection.

=head2 Commit

This method takes no arguments, and merely calls MQCMIT.  It returns
true on success, and false on failure.

NOTE: The same comments for Backout() apply here.  This is really a
Queue Manager connection operation.

=head1 ERROR HANDLING

Most methods return a true or false value indicating success of
failure, and internally, they will call the Carp subroutine (either
Carp::carp(), or something user-defined) with a text message
indicating the cause of the failure.

In addition, the most recent MQI Completion and Reason codes will be
available via the CompCode() and Reason() methods:

  $queue->CompCode()
  $queue->Reason()

When distribution lists are used, then it is possible for a list of
reason codes to be returned by the API.  Normally, these are buried
inside the ObjDesc strucure, but they are also available via the

  $queue->Reasons()

method.  In this case, the $queue->Reason() will always return
MQRC_MULTIPLE_REASONS.  The return value of the Reasons() method is an
array reference, and each array item is a hash reference with two
keys: CompCode and Reason.  These correspond, respectively, with the
CompCode and Reason associated with the individual queues in the
distribution list.

For example, the Reason code associated with the 3rd queue in the list
would be:

  $queue->Reasons()->[2]->{Reason}

In the case of the constructor new(), which returns nothing when it
fails, these methods are not available.  Most applications will not
need to handle the specific CompCode and Reason when the instantiation
fails, but if necessary, these can be obtained in one of two ways.

The older method, which is supported for backwards compabitility but
strongly discouarged, is to pass references to scalar variables to
new().  See the new() documentation above for more details.

The newer method would be to explicitly call the Open() method, and
error check it yourself.  This will mean that the constructor will now
fail only if there is an error processing the constructor arguments,
as opposed to an error in the MQSeries infrastructure.

Some examples should make this clear.

The simplest way to create an MQSeries::Queue object is:

  my $queue = MQSeries::Queue->new
    (
     QueueManager		=> 'some.queue.manager',
     Queue			=> 'SOME.QUEUE',
     Mode			=> 'input',
    ) || die;

But in this case, either the connection to the queue manager or the
open of the queue could fail, and your application will not be able to
determine why.

In order to explicitly have access to the CompCode and Reason one
would do the following:

  # Explicitly create your own MQSeries::QueueManager object
  my $qmgr = MQSeries::QueueManager->new
    (
     QueueManager		=> 'some.queue.manager',
     DisableAutoConnect		=> 1,
    ) || die "Unable to instantiate MQSeries::QueueManager object\n";

  # Call the Connect method explicitly
  unless ( $qmgr->Connect() ) {
    die("Connection to queue manager failed\n" .
        "CompCode => " . $qmgr->CompCode() . "\n" .
        "Reason   => " . $qmgr->Reason() . "\n");
  }

  my $queue = MQSeries::Queue->new
    (
     QueueManager		=> $qmgr,
     Queue			=> 'SOME.QUEUE',
     Mode			=> 'input',
     NoAutoOpen			=> 1,
    ) || die "Unable to instantiate MQSeries::Queue object\n";

  # Call the Open method explicitly
  unless ( $queue->Open() ) {
    die("Open of queue failed\n" .
        "CompCode => " . $queue->CompCode() . "\n" .
        "Reason   => " . $queue->Reason() . "\n");
  }

=head1 SEE ALSO

MQSeries(3), MQSeries::QueueManager(3), MQSeries::Message(3),
MQSeries::Message::Storable(3)

=cut
