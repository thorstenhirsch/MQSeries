#
# $Id: QueueManager.pm,v 12.4 2000/03/03 17:38:01 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::QueueManager;

require 5.004;

use strict qw(vars refs);
use Carp;
use English;

use MQSeries;
#
# Well, now that we're using the same constants for the Inquire/Set
# interface, they no longer are really part of the Command/PCF
# heirarchy.  We may or may not address this namespace asymmetry in a
# future release.
#
use MQSeries::Command::PCF;

use vars qw($VERSION);

$VERSION = '1.09';

sub new {

    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    my $self =
      {
       Carp		=> \&carp,
       RetryCount 	=> 0,
       RetrySleep 	=> 60,
       RetryReasons	=> {
			    map { $_ => 1 }
			    (
			     MQRC_CONNECTION_BROKEN,
			     MQRC_Q_MGR_NOT_AVAILABLE,
			     MQRC_Q_MGR_QUIESCING,
			     MQRC_Q_MGR_STOPPING,
			    )
			   },
       ConnectArgs	=> {},
      };
    bless ($self, $class);

    #
    # First thing -- override the Carp routine if given.
    #
    if ( $args{Carp} ) {
	if ( ref $args{Carp} ne "CODE" ) {
	    carp "Invalid argument: 'Carp' must be a CODE reference";
	    return;
	} else {
	    $self->{Carp} = $args{Carp};
	}
    }

    #
    # Minimally, the QueueManager is a required option.
    #
    # Uh, well, if you are using the "default" queue manager, we have
    # to allow this to be optional.
    #
    if ( $args{QueueManager} ) {
	if ( ref $args{QueueManager} && $args{QueueManager}->isa("MQSeries::QueueManager") ) {
	    $self->{QueueManager} = $args{QueueManager}->{QueueManager};
	} else {
	    $self->{QueueManager} = $args{QueueManager};
	}
    } else {
	$self->{QueueManager} = "";
    }

    #
    # Sanity check the data conversion CODE snippets.
    #
    foreach my $key ( qw( PutConvert GetConvert ) ) {
	if ( $args{$key} ) {
	    if ( ref $args{$key} ne "CODE" ) {
		$self->{Carp}->("Invalid argument: '$key' must be a CODE reference");
		return;
	    } else {
		$self->{$key} = $args{$key};
	    }
	}
    }

    #
    # Sanity check the other optional attributes.  Anything else in
    # the arguments is ignored.  Developer beware.  RTFM.  Yada yada
    # yada.
    #
    foreach my $connectarg ( qw( RetryCount RetrySleep RetryReasons ) ) {
	next unless exists $args{$connectarg};
	$self->{ConnectArgs}->{$connectarg} = $args{$connectarg};
    }

    #
    # OK, now, try to connect (unless told not to).
    #
    unless ( $args{NoAutoConnect} ) {
	my $result = $self->Connect();
	foreach my $code ( qw( CompCode Reason )) {
	    if ( ref $args{$code} eq "SCALAR" ) {
		${$args{$code}} = $self->{$code};
   	    }
	}
	return unless $result;
    }

    return $self;

}

sub Open {

    my $self = shift;
    my %args = @_;

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    #
    # If the options are given, we assume you know what you're doing.
    #
    if ( exists $args{Options} ) {
	$self->{Options} = $args{Options};
    } else {
	$self->{Options} = MQOO_INQUIRE | MQOO_FAIL_IF_QUIESCING;
    }

    #
    # Same for the ObjDesc
    #
    if ( exists $args{ObjDesc} ) {
	if ( ref $args{ObjDesc} eq "HASH" ) {
	    $self->{ObjDescPtr} = $args{ObjDesc};
	} else {
	    $self->{Carp}->("Invalid argument: 'ObjDesc' must be a HASH reference");
	    return;
	}
    } else {
	$self->{ObjDescPtr} =
	  {
	   ObjectType		=> MQOT_Q_MGR,
	  };
    }

    #
    # Open the Queue
    #
    $self->{Hobj} = MQOPEN(
			   $self->{Hconn},
			   $self->{ObjDescPtr},
			   $self->{Options},
			   $self->{"CompCode"},
			   $self->{"Reason"},
			  );

    if ( $self->{"CompCode"} == MQCC_OK ) {
	return 1;
    } elsif ( $self->{"CompCode"} == MQCC_FAILED ) {
	$self->{Carp}->(qq/MQOPEN failed (Reason = $self->{"Reason"})/);
	return;
    } else {
	$self->{Carp}->(qq/MQOPEN failed, unrecognized CompCode: '$self->{"CompCode"}'/);
	return;
    }

}


sub Close {

    my $self = shift;
    my (%args) = @_;

    return 1 unless $self->{Hobj};

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    MQCLOSE(
	    $self->{Hconn},
	    $self->{Hobj},
	    MQCO_NONE,
	    $self->{"CompCode"},
	    $self->{"Reason"},
	   );
    if ( $self->{"CompCode"} == MQCC_OK ) {
	delete $self->{Hobj};
	return 1;
    } elsif ( $self->{"Reason"} == MQRC_HCONN_ERROR ) {
	delete $self->{Hobj};
	return 1;
    } else {
	$self->{Carp}->("MQCLOSE of $self->{ObjDescPtr}->{ObjectName} on " .
			qq/$self->{QueueManager} failed (Reason = $self->{"Reason"})/);
	return;
    }

}
	
sub ObjDesc {

    my $self = shift;

    if ( $_[0] ) {
	if ( exists $self->{ObjDescPtr}->{$_[0]} ) {
	    return $self->{ObjDescPtr}->{$_[0]};
	} else {
	    $self->{Carp}->("No such ObjDescPtr field: $_[0]");
	    return;
	}
    } else {
	return $self->{ObjDescPtr};
    }

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
    return $self->{ObjDescPtr}->{ResponseRecs};
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

	unless ( exists $RequestValues->{QueueManager}->{$key} ) {
	    $self->{Carp}->("Unrecognized Queue attribute: '$key'");
	    return;
	}

	push(@keys,$RequestValues->{QueueManager}->{$key});

    }

    my (@values) = MQINQ(
			 $self->{Hconn},
			 $self->{Hobj},
			 $self->{"CompCode"},
			 $self->{"Reason"},
			 @keys,
			);

    unless ( $self->{"CompCode"} == MQCC_OK && $self->{"Reason"} == MQRC_NONE ) {
	$self->{Carp}->("MQINQ call failed. " .
			qq/CompCode => '$self->{"CompCode"}', / .
			qq/Reason   => '$self->{"Reason"}'\n/);
	return;
    }

    # In case the data parsing fails...
    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    my (%values) = ();

    for ( my $index = 0 ; $index <= $#keys ; $index++ ) {
	
	my ($key,$value) = ($keys[$index],$values[$index]);

	my ($newkey,$ResponseValues) = @{$ResponseParameters->{QueueManager}->{$key}};

	if ( $ResponseValues ) {
	    unless ( exists $ResponseValues->{$value} ) {
		$self->{Carp}->("Unrecognized value '$value' for key '$newkey'\n");
		return;
	    }
	    $values{$newkey} = $ResponseValues->{$value};
	} else {
	    $values{$newkey} = $value;
	}

    }

    $self->{"CompCode"} = MQCC_OK;
    $self->{"Reason"} = MQRC_NONE;

    return %values;

}

sub Disconnect {

    my $self = shift;

    return 1 unless $self->{Hconn};

    #
    # This should protect us from disconnecting from a queue manager
    # when this object is destroyed in a forked child process.
    #
    return 1 unless exists $MQSeries::QueueManager::Pid2Hconn{$$};

    #
    # This should protect us from disconnecting when a given Hconn has
    # been reused by more than one object.  The order the objects are
    # created or destroyed shouldnot matter.
    #
    return 1 if $MQSeries::QueueManager::Pid2Hconn{$$}->{$self->{Hconn}}-- > 1;

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    MQDISC(
	   $self->{Hconn},
	   $self->{"CompCode"},
	   $self->{"Reason"},
	  );
    if ( $self->{"CompCode"} == MQCC_OK ) {
	delete $self->{Hconn};
	return 1;

    } else {
	$self->{Carp}->(qq/MQDISC of $self->{QueueManager} failed (Reason = $self->{"Reason"})/);
	return;
    }

}

sub DESTROY {
    my $self = shift;
    $self->Close();
    $self->Disconnect();
}

sub Backout {

    my $self = shift;
    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    MQBACK(
	   $self->{Hconn},
	   $self->{"CompCode"},
	   $self->{"Reason"},
	  );
    if ( $self->{"CompCode"} == MQCC_OK ) {
	return 1;
    } else {
	$self->{Carp}->(qq/MQBACK of $self->{QueueManager} failed (Reason = $self->{"Reason"})/);
	return;
    }

}

sub Commit {

    my $self = shift;
    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    MQCMIT(
	   $self->{Hconn},
	   $self->{"CompCode"},
	   $self->{"Reason"},
	  );
    if ( $self->{"CompCode"} == MQCC_OK ) {
	return 1;
    } else {
	$self->{Carp}->(qq/MQCMIT of $self->{QueueManager} failed (Reason = $self->{"Reason"})/);
	return;
    }

}

sub Put1 {

    my $self = shift;
    my %args = @_;

    my $ObjDesc = {};
    my $PutMsgOpts =
      {
       Options			=> MQPMO_FAIL_IF_QUIESCING,
      };

    my $retrycount = 0;
    my $buffer = undef;

    unless ( ref $args{Message} and $args{Message}->isa("MQSeries::Message") ) {
	$self->{Carp}->("Invalid argument: 'Message' must be an MQSeries::Message object");
	return;
    }

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;

    unless ( $args{"ObjDesc"} or $args{Queue} ) {
	$self->{Carp}->("Invalid argument: either 'ObjDesc' or " .
			"'Queue' must be specified");
	return;
    }

    if ( $args{"ObjDesc"} ) {
	unless ( ref $args{"ObjDesc"} eq 'HASH' ) {
	    $self->{Carp}->("Invalid ObjDesc argument; must be a HASH reference");
	    return;
	}
	$ObjDesc = $args{"ObjDesc"};
    } else {
	if ( ref $args{Queue} eq "ARRAY" ) {
	    $ObjDesc->{ObjectRecs} = $args{Queue};
	} else {
	    $ObjDesc->{ObjectName} = $args{Queue};
	    $ObjDesc->{ObjectQMgrName} = $args{QueueManager};
	}
    }

    if ( $args{PutMsgOpts} ) {
	unless ( ref $args{PutMsgOpts} eq 'HASH' ) {
	    $self->{Carp}->("Invalid PutMsgOpts argument; must be a HASH reference");
	    return;
	}
	$PutMsgOpts = $args{PutMsgOpts};
    } else {
	if ( $args{PutMsgRecs} ) {
	    $PutMsgOpts->{PutMsgRecs} = $args{PutMsgRecs};
	}
	if ( $args{Sync} ) {
	    $PutMsgOpts->{Options} |= MQPMO_SYNCPOINT;
	} else {
	    $PutMsgOpts->{Options} |= MQPMO_NO_SYNCPOINT;
	}
    }

    #
    # Sanity check the data conversion CODE snippets.
    #
    if ( $args{PutConvert} ) {
	if ( ref $args{PutConvert} ne "CODE" ) {
	    $self->{Carp}->("Invalid argument: 'PutConvert' must be a CODE reference");
	    return;
	} else {
	    $buffer = $args{PutConvert}->($args{Message}->Data());
	}
    } else {
	if ( $args{Message}->can("PutConvert") ) {
	    $buffer = $args{Message}->PutConvert($args{Message}->Data());
	} elsif ( ref $self->{PutConvert} eq "CODE" ) {
	    $buffer = $self->{PutConvert}->($args{Message}->Data());
	} else {
	    $buffer = $args{Message}->Data();
	}
    }

    unless ( defined $buffer ) {
	$self->{Carp}->("Data conversion hook (PutConvert) failed.");
	return;
    }

    MQPUT1(
	   $self->{Hconn},
	   $ObjDesc,
	   $args{Message}->MsgDesc(),
	   $PutMsgOpts,
	   $buffer,
	   $self->{"CompCode"},
	   $self->{"Reason"},
	  );
    if ( $self->{"CompCode"} == MQCC_OK ) {
	return 1;
    } elsif ( $self->{"CompCode"} == MQCC_WARNING ) {
	# This is true in lots of cases.
	return 1;
    } else {
	$self->{Carp}->(qq/MQPUT1 failed (Reason = $self->{"Reason"})/);
	return;
    }

}

sub Connect {

    my $self = shift;
    my %args = ( %{$self->{ConnectArgs}}, @_ );

    return 1 if $self->{Hconn};

    $self->{"CompCode"} = MQCC_FAILED;
    $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;
    my $retrycount = 0;

    foreach my $key ( qw( RetryCount RetrySleep ) ) {
	next unless exists $args{$key};
	unless ( $args{$key} =~ /^\d+$/ ) {
	    $self->{Carp}->("Invalid argument: '$key' must numeric");
	    return;
	}
	$self->{$key} = $args{$key};
    }

    if ( $args{RetryReasons} ) {

	unless (
		ref $args{RetryReasons} eq "ARRAY" ||
		ref $args{RetryReasons} eq "HASH"
	       ) {
	    $self->{Carp}->("Invalid Argument: 'RetryReasons' must be an ARRAY or HASh reference");
	    return;
	}

	if ( ref $args{RetryReasons} eq 'HASH' ) {
	    $self->{RetryReasons} = $args{RetryReasons};
	} else {
	    $self->{RetryReasons} = { map { $_ => 1 } @{$args{RetryReasons}} };
	}

    }

  CONNECT:
    {

	my $Hconn = MQCONN(
			   $self->{ProxyQueueManager} || $self->{QueueManager},
			   $self->{"CompCode"},
			   $self->{"Reason"},
			  );
	if ( $self->{"CompCode"} == MQCC_OK ) {
	    $self->{Hconn} = $Hconn;
	    $MQSeries::QueueManager::Pid2Hconn{$$}->{$self->{Hconn}}++;
	    return 1;
	} elsif ( $self->{"CompCode"} == MQCC_WARNING ) {
	    if ( $self->{"Reason"} == MQRC_ALREADY_CONNECTED ) {
	        $self->{Hconn} = $Hconn;
		$MQSeries::QueueManager::Pid2Hconn{$$}->{$self->{Hconn}}++;
		return 1;
	    } else {
		$self->{Carp}->("MQCONN failed (CompCode = MQCC_WARNING), " .
				qq/but Reason is unrecognized: '$self->{"Reason"}'/);
		return;
	    }
	} elsif ( $self->{"CompCode"} == MQCC_FAILED ) {

            if ( exists $self->{RetryReasons}->{$self->{"Reason"}} ) {

		if ( $retrycount < $self->{RetryCount} ) {
		    $retrycount++;
		    $self->{Carp}->(qq/MQCONN failed (Reason = $self->{"Reason"}), will sleep / .
				    "$self->{RetrySleep} seconds and retry...");
		    sleep $self->{RetrySleep};
		    redo CONNECT;
		} else {
		    $self->{Carp}->(qq/MQCONN failed (Reason = $self->{"Reason"}), retry timed out./);
		    return;
		}
		
	    } else {
		$self->{Carp}->(qq/MQCONN failed (Reason = $self->{"Reason"}), not retrying./);
		return;
	    }

	} else {
	    $self->{Carp}->(qq/MQCONN failed, unrecognized CompCode: '$self->{"CompCode"}'/);
	    return;
	}

    }

}

1;

__END__

=head1 NAME

MQSeries::QueueManager - OO interface to the MQSeries Queue Manager

=head1 SYNOPSIS

  use MQSeries;
  use MQSeries::QueueManager;

  #
  # Simplest usage
  #
  my $qmgr = MQSeries::QueueManager->new( QueueManager => 'some.queue.manager' ) ||
    die("Unable to connect to queue manager\n");

  #
  # Slightly more complicated, obtaining the CompCode and Reason code,
  # and checking it yourself.  
  #
  my $CompCode = MQCC_FAILED;
  my $Reason = MQRC_UNEXPECTED_ERROR;
  my $qmgr = MQSeries::QueueManager->new
    (
     QueueManager 	=> 'some.queue.manager',
     CompCode 		=> \$CompCode,
     Reason 		=> \$Reason,
    );

  if ( $CompCode == MQCC_FAILED ) {
      die("Unable to connect to queue manager\n" .
	  "CompCode => $CompCode\n" .
	  "Reason => $Reason\n");
  }
  if ( $Reason == MQRC_ALREADY_CONNECTED ) {
      warn "Duplicate connection to some.queue.manager";
  }
 
  #
  # Advanced usage, setting optional arguments
  #
  my $qmgr = MQSeries::QueueManager->new
    (
     QueueManager 	=> 'some.queue.manager',
     Carp 		=> \&MyLogger,
     RetryCount 	=> 60,
     RetrySleep 	=> 10,
    ) || die("Unable to connect to queue manager\n");

  #
  # Advanced usage, setting Queue Manager wide default put and get
  # conversion routines.
  #
  my $qmgr = MQSeries::QueueManager->new
    (
     QueueManager 	=> 'some.queue.manager',
     PutConvert 	=> \&my_encrypt,
     GetConvert 	=> \&my_decrypt,
    ) || die("Unable to connect to queue manager\n");

=head1 DESCRIPTION

The MQSeries::QueueManager object is an OO mechanism for connecting to
an MQSeries queue manager.

This module is used together with MQSeries::Queue and
MQSeries::Message, and the other MQSeries::* modules.  These objects
provide a simpler, higher level interface to the MQI.

The primary value added by this particular object interface is logic
to retry the connection under certain failure conditions.  Basically,
any Reason Code which represents a transient condition, such as a
Queue Manager shutting down, or a connection lost (possibly due to a
network glitch?), will result in the MQCONN call being retried, after
a short sleep.  See below for how to tune this behavior.

This is intended to allow developers to write MQSeries applications
which recover from short term outages without intervention.  This
behavior is critically important to the authors applications, but may
not be right for yours.  By default, the retry parameters are 0, so
this is effectively disabled.

=head1 METHODS

=head2 new

The constructor takes a hash as an argument, with the following keys:

  Key            		Value
  ===            		=====
  QueueManager  		String
  Carp           		CODE reference
  NoAutoConnect			Boolean
  RetryCount     		Numeric
  RetrySleep     		Numeric
  GetConvert     		CODE reference
  PutConvert     		CODE reference
  CompCode       		Reference to Scalar Variable
  Reason         		Reference to Scalar Variable
  RetrySleep			Numeric
  RetryCount			Numeric
  RetryReasons			HASH Reference

=over 4

=item QueueManager

This is simply the name of the Queue Manager to which to connect.
This is passed directly to the MQCONN() call as-is.

Normally, this is simply the name of the queue manager to which you
wish to connect, but if the "default" queue manager is to be used,
then this can either be the empty string "", or simply omitted
entirely.

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

  my $qmgr = MQSeries::QueueManager->new
    (
     QueueManager 	=> 'some.queue.manager',
     Carp 		=> \&MyLogger,
    ) || die("Unable to connect to queue manager.\n");

The default, as one might guess, is Carp::carp();

=item RetryCount

This is an integer value, and specifies the maximum number of times to
retry the connection, before failing.  The default is 0.

=item RetrySleep

This is an integer value, and specified the number of seconds to sleep
between retries.  The maximum timeout for an outage is the product of
the RetrySleep and RetryCount parameters.  The default is 0.

=item PutConvert, GetConvert

These are CODE references to subroutines which are used to convert the
data in a MQSeries::Message object prior to passing it to the MQPUT
MQI call, or convert the data retreived from the queue by the MQGET
MQI call before inserting it into a MQSeries::Message object.

These must be CODE references, or the new() constructor will fail.  A
properly written conversion routine will be passed a single scalar
value and return a single scalar value.  In the event of an error, the
conversion routine should return 'undef'.

The example shown in the synopsis shows how one might use a pair of
home grown encryption and decryption subroutines to keep data in clear
text in core, but encrypted in the contents of the message on the
queue.  This is probably not the most hi-tech way to encrypt MQSeries
data, of course.

The MQSeries::Message::Storable class provides an example of how to
subclass MQSeries::Message to have this type of conversion handled
transparently, in the class definition.

=item CompCode, Reason

WARNING: These keys are deprecated, and their use no longer
encouraged.  They are left in place only for backwards compabitility.

See the docs for the NoAutoConnect argument, and the Connect()
method.

When the constructor encounters an error, it returns nothing, and you
can not make method calls off of a non-existent object.  Thus, you do
not have access to the CompCode() and Reason() method calls.  If you
want to extract these values, you will have to pass a scalar reference
value to the constructor, for example:

  my $CompCode = MQCC_FAILED;
  my $Reason = MQRC_UNEXPECTED_ERROR;

  my $qmgr = MQSeries::QueueManager->new
    (
     QueueManager		=> 'some.queue.manager',
     CompCode			=> \$CompCode,
     Reason			=> \$Reason,
    ) || die "Unable to open queue: CompCode => $CompCode, Reason => $Reason\n";

But, this is ugly (authors opinion, but then, he gets to write the
docs, too).  

=item RetryCount

The call to MQCONN() (implemented via the Connect() method), can be
old to retry the failure for a specific list of reason codes.  This
functionality is only enabled if the RetryCount is non-zero. By
default, this value is zero, and thus retries are disabled.

=item RetrySleep

This argument is the amount of time, in seconds, to sleep between
subsequent retry attempts.

=item RetryReasons

This argument is either an ARRAY or HASH reference indicating the
specific reason code for which retries will be attempted.  If given as
an ARRAY, the elements are simply the reason codes, and if given as a
HASH, then the keys are the reason codes (and the values ignored).

=back

=head2 Connect

This method takes no arguments, and merely calls MQCONN() to connect
to the queue manager.  The various options are all set via the
MQSeries::Queue constructor (see above).

This method is called automatically by the constructor, unless the
NoAutoConnect argument is given.

Note that this is a new method as of the 1.06 release, and is provided
to enable more fine grained error checking.  See the ERROR HANDLING
section.

=head2 Disconnect

This methodtakes no arguments, and merely calls MQDISC() to disconnect
from the queue manager.

It is important to note that normally, this method need not be called,
since it is implicitly called via the object destructor.  If the
Disconnect() call errors need to be handled, then it can be done
explicitly.  See the ERROR HANDLING section.

=head2 Backout

This method takes no arguments, and merely calls MQBACK.  It returns
true on success, and false on failure.

=head2 Commit

This method takes no arguments, and merely calls MQCMIT.  It returns
true on success, and false on failure.

=head2 Put1

This method wraps the MQPUT1 call.  The arguments are a hash, with the
following key/value pairs (required keys are marked with a '*'):

  Key           Value
  ===           =====
  Message*      MQSeries::Message object
  Queue         String, or ARRAY reference (distribution list)
  QueueManager  String
  ObjDesc       HASH reference
  PutMsgOpts    HASH Reference
  PutMsgRecs    ARRAY Reference
  Sync          Boolean
  PutConvert    CODE reference

=over 4

=item Message

This argument is the message to be placed onto the queue.  The value
must be an MQSeries::Message object.

=item Queue

This is the queue, or list of queue if using a distribution list, to
which to put the message.  If it is a single queue, then this value is
a string, naming the queue.  If it is a distribution list, then this
value is an ARRAY reference, listing the target queues.  There are
three ways to specify the list.

The list may be a simple array of strings:

  $qmgr->Put1(
              Message => $message,
              Queue => [qw( QUEUE1 QUEUE2 QUEUE3 )],
             )

or, it can be an array of arrays, each one specifying the queue and
queue manager name of the target queue:

  $qmgr->Put1(
              Message => $message,
              Queue => [
                        [qw( QUEUE1 QM1 )],
                        [qw( QUEUE2 QM2 )],
                        [qw( QUEUE3 QM3 )],
                       ],
             )

or finally, it can be an array of hash references, each naming the
queue and queue manager:

  $qmgr->Put1(
              Message => $message,
              Queue => [
	                {
			 ObjectName		=> 'QUEUE1',
			 ObjectQMgrName		=> 'QM1',
			},
		        {
			 ObjectName		=> 'QUEUE2',
			 ObjectQMgrName		=> 'QM2',
			},
			{
			 ObjectName		=> 'QUEUE3',
			 ObjectQMgrName		=> 'QM3',
			},
                       ],
              )

In the latter two cases, the queue manager names are optional.  Which
method to use is largely a choice of style.

=item QueueManager

Note that this key is B<only> relevant when not using distribution
lists.  This identifies the queue manager of the target queue, to
which the message is being written.  This is an optional key.

=item ObjDesc

The entire ObjDesc structure passed to the underlying MQPUT1() call
can be specified via this key.  In this case, the Queue and/or
QueueManager are simply ignored.  Use of this key would be considered
somewhat non-conventional, as the OO API is attempting to hide the
complexity of these underlying data structures.

However, this allows the developer access to the entire ObjDesc, if
necessary.  

=item PutMsgOpts

This argument forces the developer to specify the complete PutMsgOpts
structure, and will override the use of convenience flags, such as
Sync.  Similar to the use of ObjDesc, this is non-conventional, but
provided to allow access to the complete API, if necessary.

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

See the new() constuctor documentation for the verbose details.  This
can be specified for just the Put1() method in the event that a
converted message format needs to be put to a queue on a
MQSeries::QueueManager object for which default conversion routines
have not been installed.

If you have a QueueManager for which all of the Queue use the same
message formats, then you can simply specify the PutConvert and
GetConvert CODE references once, when the MQSeries::QueueManager
object is instantiated.  Alternately, you may be specifying the
conversion routined for only a few specific queues.  In the latter
case, it is entirely possible that you will need to specify PutConvert
when performing an MQPUT1 MQI call via the Put1() method.

=item CompCode

This method returns the MQI Completion Code for the most recent MQI
call attempted.

=item Reason

This method returns the MQI Reason Code for the most recent MQI
call attempted.

=item Reasons

This method call returns an array reference, and each member of the
array is a Response Record returned as a possible side effect of
calling a Put1() method to put a message to a distribution list.

The individual records are hash references, with two keys: CompCode
and Reason.  Each provides the specific CompCode and Reason associated
with the put of the message to each individual queue in the
distribution list, respectively.

=back

=head2 Open

This method takes two optional (but typically not necessary)
arguments, and calls MQOPEN() on the Queue Manager, in order to enable
the Inquire method.  The arguments are a has, with the following
keys:

  Key            		Value
  ===            		=====
  Options			MQOPEN 'Options' Values
  ObjDesc			HASH reference (MQOD structure)

The Options default to MQOO_INQUIRE|MQOO_FAIL_IS_QUIESCING, which is
usually correct.  Note that you can not call MQSET() on a queue
manager, so MQOO_SET is meaningless, as are most of the other options.
Advanced users can set this as they see fit.

The ObjDesc argument is also not terribly interesting, as you most of
the values have reasonable defaults for a queue manager.  Again, the
API supports advanced users, so you can set this as you see fit.  The
keys of the ObjDesc hash are the fields in the MQOD structure.

This method returns a true of false values depending on its success or
failure.  Investigate the CompCode() and Reason() for
MQSeries-specific error codes.

=head2 Close

This method takes no arguments, and merely calls MQCLOSE() to close
the actual queue manager object.  This is meaningful only if the queue
manager has been Open()ed for use by Inquire().

It is important to note that normally, this method need not be called,
since it is implicitly called via the object destructor, if necessary.
If the Close() call errors need to be handled, then it can be done
explicitly.  See the ERROR HANDLING section.

=head2 Inquire

This method is an interface to the MQINQ() API call, however, it takes
more convenient, human-readable strings in place of the C macros for
the selectors, as well as supports more readable strings for some of
the data values as well.

For example, to query the Platform and DeadLetterQName of a queue
manager:

  my %qmgrattr = $qmgr->Inquire( qw(Platform DeadLetterQName) );

The argument to this method is a list of "selectors", or QueueManager
attributes, to be queried.  The following table shows the complete set
of possible keys, and their underlying C macro.

Note that this list is all-inclusive, and that many of these are not
supported on some of the MQSeries platforms.  Consult the IBM
documentation for such details.

    Key				Macro
    ===				=====
    AlterationDate              MQCA_ALTERATION_DATE
    AlterationTime              MQCA_ALTERATION_TIME
    AuthorityEvent              MQIA_AUTHORITY_EVENT
    ChannelAutoDef              MQIA_CHANNEL_AUTO_DEF
    ChannelAutoDefEvent         MQIA_CHANNEL_AUTO_DEF_EVENT
    ChannelAutoDefExit          MQCA_CHANNEL_AUTO_DEF_EXIT
    ClusterWorkLoadData         MQCA_CLUSTER_WORKLOAD_DATA
    ClusterWorkLoadExit         MQCA_CLUSTER_WORKLOAD_EXIT
    ClusterWorkLoadLength       MQIA_CLUSTER_WORKLOAD_LENGTH
    CodedCharSetId              MQIA_CODED_CHAR_SET_ID
    CommandInputQName           MQCA_COMMAND_INPUT_Q_NAME
    CommandLevel                MQIA_COMMAND_LEVEL
    DeadLetterQName             MQCA_DEAD_LETTER_Q_NAME
    DefXmitQName                MQCA_DEF_XMIT_Q_NAME
    DistLists                   MQIA_DIST_LISTS
    InhibitEvent                MQIA_INHIBIT_EVENT
    LocalEvent                  MQIA_LOCAL_EVENT
    MaxHandles                  MQIA_MAX_HANDLES
    MaxMsgLength                MQIA_MAX_MSG_LENGTH
    MaxPriority                 MQIA_MAX_PRIORITY
    MaxUncommittedMsgs          MQIA_MAX_UNCOMMITTED_MSGS
    PerformanceEvent            MQIA_PERFORMANCE_EVENT
    Platform                    MQIA_PLATFORM
    QMgrDesc                    MQCA_Q_MGR_DESC
    QMgrIdentifier              MQCA_Q_MGR_IDENTIFIER
    QMgrName                    MQCA_Q_MGR_NAME
    RemoteEvent                 MQIA_REMOTE_EVENT
    RepositoryName              MQCA_REPOSITORY_NAME
    RepositoryNamelist          MQCA_REPOSITORY_NAMELIST
    StartStopEvent              MQIA_START_STOP_EVENT
    SyncPoint                   MQIA_SYNCPOINT
    TriggerInterval             MQIA_TRIGGER_INTERVAL

The return value of this method is a hash, whose keys are those given
as arguments, and whose values are the queried queue manager
attributes.  In almost all cases, the values are left unmolested, but
in the following case, the values are mapped to more readable strings.

=over 4

=item Platform			(integer)

    Key				Macro
    ===				=====
    MVS                         MQPL_MVS
    NSK                         MQPL_NSK
    OS2                         MQPL_OS2
    OS400                       MQPL_OS400
    UNIX                        MQPL_UNIX
    Win16                     	MQPL_WINDOWS
    Win32                  	MQPL_WINDOWS_NT

=back

=head2 ObjDesc

This method can be used to query the ObjDesc data structure.  If no
argument is given, then the ObjDesc hash reference is returned.  If a
single argument is given, then this is interpreted as a specific key,
and the value of that key in the ObjDesc hash is returned.

NOTE: This method is meaningless unless the queue manager has been
MQOPEN()ed via the Open() method.

=head1 MQCONN RETRY SUPPORT

Normally, when MQCONN() fails, the method that called it (Connect() or
new()) also fails.  It is possible to have the Connect() method retry
the MQOPEN() call for a specific set of reason codes.

By default,  the retry logic  is  disabled, but it  can  be enabled by
setting the RetryCount to a non-zero value.  The  list of reason codes
defaults to a few reasonable values, but a list of retryable codes can
be specified via the RetryReasons argument.

You are probably wondering why this logic is useful for MQCONN().  The
choice of the default RetryReasons is not without its own reason.

Consider an application that loses its connection to its queue
manager, and thus crashes and restarts.  It may very well attempt to
reconnect before the queue manager has recovered, and this support
allows the application to retry the connection for a while, until it
succeeds.

Alternately, consider an application that is started at boot time,
possible in parallel with the queue manager.  If the application comes
up before the queue manager, the MQCONN() call will fail.  Retrying
this initial connection will make the application startup more robust.

This makes it easier to have applications recover from queue manager
failures, or that have more robust startup logic, but note that this
retry logic only applies to the initial connection.  Reconnecting at
arbitrary points in the code is far more complex, and it left as a
(painful) exercise to the reader.

=head1 ERROR HANDLING

Most methods return a true or false value indicating success of
failure, and internally, they will call the Carp subroutine (either
Carp::Carp, or something user-defined) with a text message indicating
the cause of the failure.

In addition, the most recent MQI Completion and Reason codes will be
available via the CompCode() and Reason() methods:

  $qmgr->CompCode()
  $qmgr->Reason()

When distribution lists are used, then it is possible for a list of
reason codes to be returned by the API.  Normally, these are buried
inside the ObjDesc strucure, but they are also available via the

  $qmgr->Reasons()

method.  In this case, the $queue->Reason() will always return
MQRC_MULTIPLE_REASONS.  The return value of the Reasons() method is an
array reference, and each array item is a hash reference with two
keys: CompCode and Reason.  These correspond, respectively, with the
CompCode and Reason associated with the individual queues in the
distribution list.

For example, the Reason code associated with the 3rd queue in the list
would be:

  $qmgr->Reasons()->[2]->{Reason}

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

The simplest way to create an MQSeries::QueueManager object is:

  my $qmgr = MQSeries::QueueManager->new
    (
     QueueManager		=> 'some.queue.manager',
    ) || die;

But in this case, the connection to the queue manager could fail, and
your application will not be able to determine why.

In order to explicitly have access to the CompCode and Reason one
would do the following:

  my $qmgr = MQSeries::QueueManager->new
    (
     QueueManager		=> 'some.queue.manager',
     NoAutoConnect		=> 1,
    ) || die "Unable to instantiate MQSeries::QueueManager object\n";

  # Call the Connect method explicitly
  unless ( $qmgr->Connect() ) {
    die("Connection to queue manager failed\n" .
        "CompCode => " . $qmgr->CompCode() . "\n" .
        "Reason   => " . $qmgr->Reason() . "\n");
  }

=head1 CONVERSION PRECEDENCE

Once you have read all the MQSeries::* documentation, you might be
confused as to how the various PutConvert/GetConvert method arguments
and constructor arguments interact with the MQSeries::Message
PutConvert() and GetConvert() methods.

The following is the precedence of the various places you can specify
a PutConvert or GetConvert subroutine, from highest to lowest:

  [A] Put(), Get(), and Put1() method arguments
  [B] MQSeries::Message PutConvert() and GetConvert() methods
  [C] MQSeries::Queue object defaults (set as arguments to new())
  [C] MQSeries::QueueManager object defaults (set as arguments to new())

The cleanest way to code these is probably (and here your mileage will
vary wildly with your tastes) to implement a subclass of
MQSeries::Message which provides the appropriate GetConvert() and
PutConvert() methods, one seperate class for each type of data
conversion which is necessary.

Then the conversion happens "under the covers" when message objects of
that class are put to or gotten from a queue.

=head1 SEE ALSO

MQSeries(3), MQSeries::Queue(3), MQSeries::Message(3)

=cut
