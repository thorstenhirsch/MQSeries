#
# $Id: Event.pm,v 22.1 2002/07/23 20:27:45 biersma Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Message::Event;

require 5.005;

use strict;
use Carp;

use MQSeries qw(:functions);
use MQSeries::Message;
use MQSeries::Message::PCF qw(MQDecodePCF);

require "MQSeries/Message/Event.pl";

use vars qw(@ISA $VERSION);

$VERSION = '1.19';
@ISA = qw(MQSeries::Message);

sub PutConvert {
    my $self = shift;
    $self->{Carp}->("MQPUTing an MQEvent object is not supported\n");
    return undef;
}

sub GetConvert {
    my $self = shift;

    ($self->{Buffer}) = @_;

    my ($header,$parameters);

    unless ( ($header,$parameters) = MQDecodePCF($self->{Buffer}) ) {
	$self->{Carp}->("Unable to parse PCF contents from message\n");
	return undef;
    }

    unless ( ($self->{EventHeader},$self->{EventData}) = $self->_TranslatePCF($header,$parameters) ) {
	$self->{Carp}->("Unable to parse MQSeries Event from message\n");
	return undef;
    }

    #
    # The message data is useless in an event -- it all gets parsed
    # into the EventHeader and Eventdata, so just feed back something
    # which is true.
    #
    return 1;

}

sub _TranslatePCF {

    my $self = shift;
    my ($origheader,$origparams) = @_;

    my $header = $origheader;
    my $parameters = {};

    my $ResponseParameters = \%MQSeries::Message::Event::ResponseParameters;

    if ( 
	$header->{Type} != MQSeries::MQCFT_EVENT ||
	(
	 $header->{Command} != MQSeries::MQCMD_Q_MGR_EVENT &&
	 $header->{Command} != MQSeries::MQCMD_PERFM_EVENT &&
	 $header->{Command} != MQSeries::MQCMD_CHANNEL_EVENT
	)
       ) {
	$self->{Carp}->("Not an MQSeries performance event\n");
	return;
    }

    foreach my $origparam ( @$origparams ) {

	my ($key,$value);

	if ( $ResponseParameters->{$origparam->{Parameter}} ) {
	    $key = $ResponseParameters->{$origparam->{Parameter}};
	}
	else {
	    $self->{Carp}->("No such parameter '$origparam->{Parameter}' " . 
			    "defined in %MQSeries::Message::Event::ResponseParameters\n");
	    $key = $origparam->{Parameter};
	}

	#
	# NOTE: events don't use the MQCFT_STRING_LIST or
	# MQCFT_INTEGER_LIST types.
	#
	
	if ( $origparam->{Type} == MQSeries::MQCFT_STRING ) {
	    ( $parameters->{$key} = $origparam->{String} ) =~ s/\s+$//;
	}

	if ( $origparam->{Type} == MQSeries::MQCFT_INTEGER ) {
	    $parameters->{$key} = $origparam->{Value};
	}

    }

    return ($header,$parameters);

}

sub EventHeader {

    my $self = shift;

    $self->{EventHeader} = {} unless $self->{EventHeader};

    if ( $_[0] ) {
	if ( exists $self->{EventHeader}->{$_[0]} ) {
	    return $self->{EventHeader}->{$_[0]};
	}
	else {
	    $self->{Carp}->("No such EventHeader field: $_[0]\n");
	    return;
	}
    }
    else {
	return $self->{EventHeader};
    }

}

sub EventData {

    my $self = shift;

    $self->{EventData} = {} unless $self->{EventData};

    if ( $_[0] ) {
	if ( exists $self->{EventData}->{$_[0]} ) {
	    return $self->{EventData}->{$_[0]};
	}
	else {
	    $self->{Carp}->("No such EventData field: $_[0]\n");
	    return;
	}
    }
    else {
	return $self->{EventData};
    }

}

1;

__END__

=head1 NAME

MQSeries::Message::Event -- OO Class for decoding MQSeries event messages

=head1 SYNOPSIS

  use MQSeries::Message::Event;
  my $message = MQSeries::Message::Event->new;

=head1 DESCRIPTION

This class is a subclass of MQSeries::Message which provides a
GetConvert() method to decode standard MQSeries Event messages.

=head1 METHODS

Since this is a subclass of MQSeries::Message, all of that classes
methods are available, as well as the following.

=head2 PutConvert, GetConvert

Neither of these methods are called by the users application, but are
used internally by MQSeries::Queue::Put() and MQSeries::Queue::Get(),
as well as MQSeries::QueueManager::Put1().

The PutConvert method will cause a failure, since this class is only
to be used for decoding MQSeries events, not generating them.  Perhaps
a futute release will support the creation of such events.

The GetConvert method decodes the message contents into the
EventHeader and EventData hashes, which are available via the methods
of the same name.

=head2 Buffer

Actually, this is one of the MQSeries::Message methods, and not
specific to MQSeries::Message::Event.  However, it is important to
note that this class is one of those that saves the raw buffer
returned by MQGET in the object.

The Buffer method will return the raw, unconverted PCF data in the
original message.  The autor uses this to echo the original event
message to other systems management software that wants to parse the
PCF.

=head2 EventHeader

This method can be used to query the EventHeader data structure.  If
no argument is given, then the entire EventHeader hash is returned.
If a single argument is given, then this is interpreted as a specific
key, and the value of that key in the EventHeader hash is returned.

The keys in the EventHeader hash are the fields from the MQCFH
structure.  See the "MQSeries Programmable System Management"
documentation.

=head2 EventData

This method can be used to query the EventData data structure.  If no
argument is given, then the entire EventData hash is returned.  If a
single argument is given, then this is interpreted as a specific key,
and the value of that key in the EventData hash is returned.

The keys in the EventData hash vary, depending on the specific event.
In general, these are the strings shown in the documentation for each
individual event described in the "MQSeries Programmable System
Management" documentation.  The data structures in the eventdata in
the original event are identified with macros, such as
"MQCA_Q_MGR_NAME".  Rather than use these (in some cases very cryptic)
macros, the strings shown in the IBM MQSeries documentation are used
instead.  In this case, "QMgrName".

The macros are mapped to strings as follows:

   Macro				Key
   =====				===
   MQCACF_APPL_NAME                     ApplName
   MQCACF_AUX_ERROR_DATA_STR_1          AuxErrorDataStr1
   MQCACF_AUX_ERROR_DATA_STR_2          AuxErrorDataStr2
   MQCACF_AUX_ERROR_DATA_STR_3          AuxErrorDataStr3
   MQCACF_BRIDGE_NAME                   BridgeName
   MQCACF_OBJECT_Q_MGR_NAME             ObjectQMgrName
   MQCACF_USER_IDENTIFIER               UserIdentifier
   MQCACH_CHANNEL_NAME                  ChannelName
   MQCACH_CONNECTION_NAME               ConnectionName
   MQCACH_FORMAT_NAME                   Format
   MQCACH_XMIT_Q_NAME                   XmitQName
   MQCA_BASE_Q_NAME                     BaseQName
   MQCA_PROCESS_NAME                    ProcessName
   MQCA_Q_MGR_NAME                      QMgrName
   MQCA_Q_NAME                          QName
   MQCA_XMIT_Q_NAME                     XmitQName
   MQIACF_AUX_ERROR_DATA_INT_1          AuxErrorDataInt1
   MQIACF_AUX_ERROR_DATA_INT_2          AuxErrorDataInt2
   MQIACF_BRIDGE_TYPE                   BridgeType
   MQIACF_COMMAND                       Command
   MQIACF_CONV_REASON_CODE              ConversionReasonCode
   MQIACF_ERROR_IDENTIFIER              ErrorIdentifier
   MQIACF_OPEN_OPTIONS                  Options
   MQIACF_REASON_QUALIFIER              ReasonQualifier
   MQIACH_CHANNEL_TYPE                  ChannelType
   MQIA_APPL_TYPE                       ApplType
   MQIA_HIGH_Q_DEPTH                    HighQDepth
   MQIA_MSG_DEQ_COUNT                   MsgDeqCount
   MQIA_MSG_ENQ_COUNT                   MsgEnqCount
   MQIA_Q_TYPE                          QType
   MQIA_TIME_SINCE_RESET                TimeSinceReset

=head1 SEE ALSO

MQSeries(3), MQSeries::QueueManager(3), MQSeries::Queue(3),
MQSeries::Message(3)

=cut
