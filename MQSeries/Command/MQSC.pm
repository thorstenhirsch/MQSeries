#
# $Id: MQSC.pm,v 15.4 2000/11/13 18:44:46 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

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
require "MQSeries/Command/MQSC/RequestValues.pl";
require "MQSeries/Command/MQSC/RequestParameterRemap.pl";
require "MQSeries/Command/MQSC/RequestParameterPrimary.pl";
require "MQSeries/Command/MQSC/RequestParameters.pl";
require "MQSeries/Command/MQSC/RequestArgs.pl";
require "MQSeries/Command/MQSC/Requests.pl";
require "MQSeries/Command/MQSC/ResponseValues.pl";
require "MQSeries/Command/MQSC/ResponseParameters.pl";
require "MQSeries/Command/MQSC/Responses.pl";

#
# This is a bit wierd....  well, all of the MQSC stuff is wierd....
# I'll try to stop whining all over the comments.
#
sub _LastSeen {

    my $self = shift;

    return unless $self->{Response}->[0] && $self->{Response}->[0]->Header('LastMsgSeqNumber') == scalar @{$self->{Response}};
    return 1;

}

sub _ProcessResponses {

    my $self = shift;
    my $command = shift;

    my $MQSCHeader = { Command => $command };
    my $MQSCParameters = {};

    #
    # Key difference with PCF: we are going to toss out some of the
    # responses, and reset the Response array.
    #
    my @response = ();

    $self->{Buffers} = [];

    foreach my $response ( @{$self->{Response}} ) {
	
	#
	# XXX -- Special hack to collect raw text
	#
	push(@{$self->{Buffers}},$response->{Buffer});

	#
	# Some MQSC commands return 2 batches of responses.
	# DISPLAY CHSTATUS sends us one saying "COMMAND ACCEPTED",
	# which we really don't care about.
	#
	if ( $response->ReasonText() =~ /COMMAND.*ACCEPTED/si ) {
	    next;
	}

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

	if ( $command eq 'InquireChannelStatus' ) {
	    if (
		(
		 $self->{"CompCode"} == 0 &&
		 $self->{"Reason"} == 4
		) ||
		$response->ReasonText() =~ /no chstatus found/mi
	       ) {
		$response->{Parameters}->{ChannelStatus} = 'NotFound';
		$self->{"Reason"} = MQRCCF_CHL_STATUS_NOT_FOUND;
	    }
	}

	#
	# Ok, now it gets even more complicated (yes, that is
	# always possible).
	#
	# Remember that we are trying very hard to have one
	# interface, and one format for the results.  PCF has
	# these InquireFooNames calls, that do *not* map
	# cleanly to MQSC.  We need to collect the multiple
	# messages into one, to keep the results in the same
	# format
	#
	if ( $MQSeries::Command::MQSC::ResponseList{$command} ) {
	    my ($oldkey,$newkey) = @{$MQSeries::Command::MQSC::ResponseList{$command}};
	    push(@{$MQSCParameters->{$newkey}},$response->Parameters($oldkey))
	      if $response->Parameters($oldkey);
	} else {
	    push(@response,$response);
	}

    }

    #
    # For these commands, we create a fake response message, and feed
    # that back.
    #
    if ( $MQSeries::Command::MQSC::ResponseList{$command} ) {
	$response = MQSeries::Command::Response->new
	  (
	   MsgDesc		=> $response->MsgDesc(),
	   Header		=> $MQSCHeader,
	   Parameters		=> $MQSCParameters,
	   Type			=> $self->{Type},
	  ) || do {
	      $self->{"CompCode"} = MQCC_FAILED;
	      $self->{"Reason"} = MQRC_UNEXPECTED_ERROR;
	      return;
	  };
	push(@response,$response);
    }

    #
    # Reset the Response list, since we're about to re-populate it.
    #
    $self->{Response} = [];

    #
    # Only send back responses which have non-empty parameters.
    # And yes, we're violating the OO concept of using methods
    # to get at data members.  We're somewhat incestuous here...
    #
    if ( @response ) {
	my $responsecount = 0;
	foreach my $response ( @response ) {
	    if ( keys %{$response->{Parameters}} ) {
		$response->{Header}->{MsgSeqNumber} = ++$responsecount;
		$response->{Header}->{Control} = &MQCFC_NOT_LAST;
		$response->{Header}->{ParameterCount} = scalar keys %{$response->{Parameters}};
		delete $response->{Header}->{LastMsgSeqNumber};
		push(@{$self->{Response}},$response);
	    }
	}
	#
	# Yank back the last response, and set its control value
	# to MQCFC_LAST
	#
	if ( scalar(@{$self->{Response}}) ) {
	    my $response = pop(@{$self->{Response}});
	    $response->{Header}->{Control} = &MQCFC_LAST;
	    push(@{$self->{Response}},$response);
	}
	#
	# One last thing.  If we now have *no* responses, then
	# pass back the first one.  This is possible if we get
	# multiple responses, but none have parameters.
	#
	else {
	    $response[0]->{Header}->{MsgSeqNumber} = 1,
	      $response[0]->{Header}->{Control} = &MQCFC_LAST;
	    $response[0]->{Header}->{ParameterCount} = 0;
	    delete $response[0]->{Header}->{LastMsgSeqNumber};
	    push(@{$self->{Response}},$response[0]);
	}
    }

    return 1;

}

1;
