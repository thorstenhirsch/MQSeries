#
# $Id: AdminMessage.pm,v 22.1 2002/07/23 20:27:11 biersma Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::PubSub::AdminMessage;

require 5.005;

use strict;
use Carp;

use MQSeries qw(:functions);
use MQSeries::Message;
use MQSeries::Message::PCF qw(MQDecodePCF);

require "MQSeries/PubSub/AdminMessage.pl";

use vars qw(@ISA $VERSION);

@ISA = qw(MQSeries::Message);

$VERSION = '1.19';

#
# Generate the message contents from the Command
#
sub PutConvert {
    my $self = shift;
    $self->{Carp}->("MQPUTing a MQSeries::PubSub::AdminMessage is not supported\n");
    return undef;
}

sub GetConvert {

    my $self = shift;
    ($self->{Buffer}) = @_;

    my ($header,$parameters);

    unless ( ($header,$parameters) = MQDecodePCF($self->{Buffer}) ) {
	$self->{Carp}->("Unable to decode PCF buffer\n");
	return undef;
    }

    unless ( ($self->{Header},$self->{Parameters}) = $self->_TranslatePCF($header,$parameters) ) {
	$self->{Carp}->("Unable to translate Header/Parameters from MQDecodePCF output\n");
	return undef;
    }

    return 1;

}

#
# This is loosely based on the same routine in
# MQSeries::Command::Response, but far simpler.
#
sub _TranslatePCF {

    my $self = shift;
    my ($origheader,$origparams) = @_;

    my $header = $origheader;
    my $index = -1;

    my ($parameters);

    # Short hand
    my $Responses =
      \%MQSeries::PubSub::AdminMessage::Responses;
    my $ResponseParameters =
      \%MQSeries::PubSub::AdminMessage::ResponseParameters;
    my $RegistrationOptions =
      \%MQSeries::PubSub::AdminMessage::RegistrationOptions;
    my $PublicationOptions =
      \%MQSeries::PubSub::AdminMessage::PublicationOptions;

    my %Type2Key =
      (
       MQSeries::MQCFT_STRING		=> 'String',
       MQSeries::MQCFT_INTEGER		=> 'Value',
      );

    unless ( exists $Responses->{$origheader->{Command}} ) {
	$self->{Carp}->("Unknown PubSub command '$origheader->{Command}'\n");
	return;
    }

    $header->{Command} = $Responses->{$origheader->{Command}};

    foreach my $origparam ( @$origparams ) {
	
	my ($newparameter,$newvalue);

	if ( exists $ResponseParameters->{$origparam->{Parameter}} ) {
	    $newparameter = $ResponseParameters->{$origparam->{Parameter}};
	}
	else {
	    #
	    # XXX - Should we perhaps just let the unrecognized
	    # parameters pass through untranslated?  The XS code did
	    # this, but whined about them.
	    #
	    $self->{Carp}->("Missing parameter '$origparam->{Parameter}'\n" .
			    "Not found in %MQSeries::PubSub::AdminMessage::ResponseParameters\n");
	    $newparameter = $origparam->{Parameter};
	}

	$newvalue = $origparam->{$Type2Key{$origparam->{Type}}};
	$newvalue =~ s/\s+$// if $origparam->{Type} == MQSeries::MQCFT_STRING;

	#
	# Convert the RegistrationRegistrationOptions (what a *vile*
	# string :-P ) to a hash whose keys are the various reg
	# options.
	#
	# NOTE: PublicationOptions and RegistrationOptions are not
	# documented in the PubSub user's guide, but they appear to
	# have the same semantics as that ugly long name next to
	# them...
	#
	if (
	    $newparameter eq "RegistrationRegistrationOptions" ||
	    $newparameter eq "RegistrationOptions"
	   ) {

	    my $oldvalue = $newvalue;
	    $newvalue = {};

	    foreach my $regopt ( keys %$RegistrationOptions ) {
		if ( $oldvalue & $regopt ) {
		    $newvalue->{$RegistrationOptions->{$regopt}}++;
		}
	    }

	}

	if ( $newparameter eq "PublicationOptions" ) {

	    my $oldvalue = $newvalue;
	    $newvalue = {};

	    foreach my $pubopt ( keys %$PublicationOptions ) {
		if ( $oldvalue & $pubopt ) {
		    $newvalue->{$PublicationOptions->{$pubopt}}++;
		}
	    }

	}

	#
	# A few of these parameters we will *always* turn into ARRAY
	# refs, since we need to maintain a consistent index for each
	# set of data.  It is possible to get a list of instances,
	# some of which are missing the CorrelId (for example).
	#
	# The Registration QMgrName is always first.
	#
	$index++ if $newparameter eq 'RegistrationQMgrName';

	if (
	    $newparameter eq 'RegistrationQMgrName' ||
	    $newparameter eq 'RegistrationQName' ||
	    $newparameter eq 'RegistrationCorrelId' ||
	    $newparameter eq 'RegistrationUserIdentifier' ||
	    $newparameter eq 'RegistrationRegistrationOptions' ||
	    $newparameter eq 'RegistrationTime'
	   ) {
	    $parameters->{$newparameter}->[$index] = $newvalue;
	}
	#
	# Some of these parameters will be repeated, to automatically
	# turn them into ARRAY references.
	#
	elsif ( exists $parameters->{$newparameter} ) {
	    if ( ref $parameters->{$newparameter} ne "ARRAY" ) {
		$parameters->{$newparameter} = [$parameters->{$newparameter}];
	    }
	    push(@{$parameters->{$newparameter}},$newvalue);
	}
	else {
	    $parameters->{$newparameter} = $newvalue;
	}

    }

    return ($header,$parameters);

}

sub CompCode {
    my $self = shift;
    if ( ref $self->{Header} ) {
	return $self->{Header}->{CompCode};
    }
    else {
	return;
    }
}

sub Reason {
    my $self = shift;
    if ( ref $self->{Header} ) {
	return $self->{Header}->{Reason};
    }
    else {
	return;
    }
}

sub Parameters {

    my $self = shift;

    unless (
	    ref $self->{Parameters} eq 'HASH' and
	    keys %{$self->{Parameters}}
	   ) {
	return;
    }

    if ( $_[0] ) {
	return $self->{Parameters}->{$_[0]};
    }
    else {
	return $self->{Parameters};
    }

}

sub Header {

    my $self = shift;

    unless (
	    ref $self->{Header} eq 'HASH' and
	    keys %{$self->{Header}}
	   ) {
	return;
    }

    if ( $_[0] ) {
	return $self->{Header}->{$_[0]};
    }
    else {
	return $self->{Header};
    }

}

1;

__END__

=head1 NAME

MQSeries::PubSub::AdminMessage -- OO Class for decoding MQSeries PubSub adminstrative messages

=head1 SYNOPSIS

  use MQSeries;
  use MQSeries::PubSub::AdminMessage;

=head1 DESCRIPTION

The MQSeries::PubSub::AdminMessage class is an abstraction for parsing
the Publish/Subscribe administrative messages which are published in
PCF (Programmable Command Format), unlike most PubSub messages which
are in the MQRFH (Rules and Formats Format).  This class is
essentially only used by systems management applications, which would
subscribe to the administrative messages published by the
Publish/Subscribe broker itself, in the SYSTEM.BROKER.ADMIN.STREAM.

See the "MQSeries Pub/Sub User's Guide", Chapter 14: "Writing system
management applications" for more details.

=head1 METHODS

The MQSeries::PubSub::Message class is a subclass of
MQSeries::Message, so it inherits all of the latters methods.  In
addition, the following methods are available (or overridden).

=head2 CompCode, Reason

These methods return the CompCode and Reason, obviously respectively,
in the MQCFH Header structure in the message.  This is to allow for a
more consistent "look and feel" to the application error handling
code.

=head2 Header, Parameters

These methods return a HASH reference which represents either the
MQCFH structure (Header) or PCF parameters (Parameters) in the
message.  When passed no arguments, the entire HASH is returned.  When
passed a single argument, then only the value of the key matching that
argument is returned.

For example:

   $message->Header("CompCode")

would be equivalent to

   $message->CompCode()

But,

   $message->Header()

would give you back the entire HASH reference, so you could also get
at the CompCode with

   $message->Header()->{CompCode}

See the "Header Format" and "Parameters Format" sections for more
details.

=head2 PutConvert, GetConvert

These are called internally by the MQSeries::Queue::Get() and
MQSeries::Queue::Put() methods, and not invoked directly by
applications.

=head1 Header Format

The Header data structure is a HASH reference whose keys are the MQCFH
PCF Header structure fields.  The supported fields returned by this
API are documented in the "MQSeries Pub/Sub User's Guide", Chapter 14:
"Writing system management applications".

Note that the values returned are all precisely as documented, with
the exception of the "Command" key.  Rather than the numerical values
of the various MQCMD_* macros, these are mapped to the following text
strings:

  Macro Name				Key
  ==========				===
  MQCMD_DELETE_PUBLICATION		DeletePublication
  MQCMD_DEREGISTER_PUBLISHER    	DeregisterPublisher
  MQCMD_DEREGISTER_SUBSCRIBER   	DeregisterSubscriber
  MQCMD_PUBLISH                 	Publish
  MQCMD_REGISTER_PUBLISHER      	RegisterPublisher
  MQCMD_REGISTER_SUBSCRIBER     	RegisterSubscriber
  MQCMD_REQUEST_UPDATE          	RequestUpdate
  MQCMD_BROKER_INTERNAL         	BrokerInternal

Note however, that only value you will ever see when subscribing to
administrative messages is "Publish", therefore the Header data is not
terribly useful or interesting.

=head1 Parameters Format

The Parameters parsed from the PCF messages depend on the specific
type of data encoded in the publication.  In most cases, the values
are either a single value, or an ARRAY reference of values when that
specific Paramater is repeated.  Most of the values are strings, but
in 3 specific cases, the values are HASH references.

Many publications return data for numerous subcribers, for example,
and each of the relevant keys will contain an ARRAY of values, the
order of which is respectively related to the individual subscriber.
Thus, the nth entry in the ARRAY for each of the repeated fields all
correspond to the same subscriber.

Thus, the correct way to deal with these results is:

  foreach my $key ( sort keys %{$message->Parameters()} ) {
    if ( ref $message->Parameters($key) eq "ARRAY" ) {
      foreach my $parameter ( @{$message->Parameters($key)} ) {
        # Do something intelligent with $parameter
      }
    }
    else {
      # Do something intellident with $message->Parameters($key)
    }
  }

=head2 Common Parameters

The following keys are returned for all publications:

=over 4

=item PublicationOptions

The value of this key is a HASH reference, whose keys represent the
individual PublicationsOptions present.

The only option which is documented to be possibly present is
MQPUBO_RETAIN_PUBLICATION, which is represented by the string
"RetPub".

Thus one would test for the existence of this flag something like:

  if ( $message->Parameters("PublicationOptions")->{RetPub} ) {
    print "Publication is retained\n";
  }

For completeness, all of the MQPUBO_* options which exist are defined,
and their string representations are as follows:

  Macro Name				Value
  ==========				=====
  MQPUBO_CORREL_ID_AS_IDENTITY   	CorrelAsId
  MQPUBO_RETAIN_PUBLICATION      	RetPub
  MQPUBO_OTHER_SUBSCRIBERS_ONLY  	OtherSubOnly
  MQPUBO_NO_REGISTRATION         	NoReg
  MQPUBO_IS_RETAINED_PUBLICATION 	IsRetPub

=item StreamName

This is set to the reserved stream name "SYSTEM.BROKER.ADMIN.STREAM".

=item Topic

This will be one of the following values:

  MQ/QMgrName/Event/SubscriptionDeregistered
  MQ/QMgrName/Event/StreamDeleted
  MQ/QMgrName/Event/BrokerDeleted
  MQ/QMgrName/StreamSupport
  MQ/QMgrName/Children
  MQ/QMgrName/Parent

where "QMgrName" is the queue manager name of the broker sending the
message, which is 48 characters long and padded with spaces.

=item PublishTimestamp

The time of publication (set to universal time).

=back

=head2 Topic Specific Parameters

The other parameters which are present in the Parameters HASH depend
on the specific type of publication, which is indicated by the Topic.
Again, for specific details, see the IBM documentation, specifically
the "MQSeries PubSub User's Guide", in particular "Part 4: System
Programming".

=head2 Special Parameter Values

In all cases other than the following, the data values for the
parameters are unmolested.  The exception is:

=over 4

=item RegistrationRegistrationOptions and RegistrationOptions

First of all, the author debated changing these strings to
"RegRegOpts" and "RegOpts" for maintenance of sanity, but then the
strings do not match up with the IBM docs.

Both of these are handled the same way as "PublicationOptions", and
the value returned is a HASH reference with the following keys
corresponding to each of the possible option flags:

  Macro Name				Value
  ==========				=====
  MQREGO_CORREL_ID_AS_IDENTITY        	CorrelAsId
  MQREGO_ANONYMOUS                    	Anon
  MQREGO_LOCAL                        	Local
  MQREGO_DIRECT_REQUESTS              	DirectReq
  MQREGO_NEW_PUBLICATIONS_ONLY        	NewPubsOnly
  MQREGO_PUBLISH_ON_REQUEST_ONLY      	PubOnReqOnly
  MQREGO_DEREGISTER_ALL               	DeregAll
  MQREGO_INCLUDE_STREAM_NAME          	InclStreamName
  MQREGO_INFORM_IF_RETAINED           	InformIfRet

=back

=head2 Undocumented Keys

Also, it is worth mentioning that there are severl keys which are not
found in the IBM documentation, but which author discovered are in
fact present in the published data experimentally (I am not making any
of this up).

  Macro Name				Key
  ==========				===
  MQCACF_PARENT_Q_MGR_NAME            	QMgrName
  MQIACF_PUBLICATION_OPTIONS          	PublicationOptions
  MQIACF_REGISTRATION_OPTIONS         	RegistrationOptions
  MQCACF_SUPPORTED_STREAM_NAME        	SupportedStreamName

=head1 SEE ALSO

  MQSeries::PubSub::Broker(3), MQSeries::PubSub::Stream(3)

  MQSeries PubSub User's Guide

=cut
