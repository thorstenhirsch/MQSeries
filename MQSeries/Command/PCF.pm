#
# $Id: PCF.pm,v 15.6 2000/11/13 22:05:46 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::PCF;

use vars qw(
	    $VERSION
	    @ISA
	   );

@ISA = qw(MQSeries::Command);

$VERSION = '1.12';

use MQSeries;

#
# Note -- the order is important, so resist the anal retentive urge to
# sort these lines in the interest of cosmetic appearance.
#
require "MQSeries/Command/PCF/RequestParameterOrder.pl";
require "MQSeries/Command/PCF/RequestParameterRequired.pl";
require "MQSeries/Command/PCF/RequestValues.pl";
require "MQSeries/Command/PCF/RequestParameters.pl";
require "MQSeries/Command/PCF/Requests.pl";
require "MQSeries/Command/PCF/ResponseValues.pl";
require "MQSeries/Command/PCF/ResponseParameters.pl";
require "MQSeries/Command/PCF/Responses.pl";

#
# We want to force the reverse mapping to be done once and only once.
#
MQSeries::Command::PCF->_ReverseMap
  (
   \%MQSeries::Command::PCF::Requests,
   \%MQSeries::Command::PCF::_Requests,
  );

MQSeries::Command::PCF->_ReverseMap
  (
   \%MQSeries::Command::PCF::Responses,
   \%MQSeries::Command::PCF::_Responses,
  );

#
# Check the Responses to see if we've seen the last one yet.  For PCF,
# this is a peice of cake.  For real fun, see the MQSC code.
#
sub _LastSeen {

    my $self = shift;
    my ($last) = reverse @{$self->{Response}};
    return unless ref $last && $last->isa("MQSeries::Command::Response");
    return unless $last->Header("Control") == MQCFC_LAST;
    return 1;

}

#
# Post process the response list.  For PCF, this just means setting
# the command objects compcode/reason to the first non-zero value
# found in the response list (and a hack for InquireChannelStatus).
#
sub _ProcessResponses {

    my $self = shift;
    my $command = shift;

    foreach my $response ( @{$self->{Response}} ) {

	#
	# Let the object-wide compcode and reason be the first
	# non-zero result found in all of the messages.  This is
	# *usually* good enough, but the data will be available via
	# Response() is you want to parse the full header for each
	# message.
	#
	if (
	    $self->{"CompCode"} == MQCC_OK && $self->{"Reason"} == MQRC_NONE &&
	    (
	     $response->Header("CompCode") != MQCC_OK ||
	     $response->Header("Reason") != MQRC_NONE
	    )
	   ) {
	    $self->{"CompCode"} = $response->Header("CompCode");
	    $self->{"Reason"} = $response->Header("Reason");
	}

	#
	# Yet another special case....
	#
	if (
	    $command eq 'InquireChannelStatus'  &&
	    $self->{"Reason"} == MQRCCF_CHL_STATUS_NOT_FOUND
	   ) {
	    $response->{Parameters}->{ChannelStatus} = 'NotFound';
	}

    }

    return 1;

}


sub _ReverseMap {

    my $class = shift;
    my $ForwardKeyMap = shift;
    my $ReverseKeyMap = shift;

    foreach my $command ( keys %$ForwardKeyMap ) {

	my $ForwardCommandMap = $ForwardKeyMap->{$command};

	my $ForwardParameterMap = $ForwardCommandMap->[1];

	my $ReverseParameterMap = {};

	foreach my $parameter ( keys %$ForwardParameterMap ) {

	    my $ForwardValueMap = $ForwardParameterMap->{$parameter}->[2];

	    if ( ref $ForwardValueMap eq 'HASH' ) {

		my $ReverseValueMap = {};

		foreach my $value ( keys %$ForwardValueMap ) {
		    $ReverseValueMap->{ $ForwardValueMap->{$value} } = $value;
		}

		$ReverseParameterMap->{ $ForwardParameterMap->{$parameter}->[0] } =
		  [ $parameter, $ReverseValueMap ];

	    } else {

		$ReverseParameterMap->{ $ForwardParameterMap->{$parameter}->[0] } =
		  [ $parameter ];

	    }

	}

	$ReverseKeyMap->{$ForwardCommandMap->[0]} = [ $command, $ReverseParameterMap ];

    }

    return 1;

}

1;
