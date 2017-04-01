#
# (c) 1999-2012 Morgan Stanley & Co. Incorporated
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::PCF;

use strict;

our @ISA = qw(MQSeries::Command);
our $VERSION = '1.35';

use MQSeries qw(:functions :constants);

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
# this is a piece of cake.  For real fun, see the MQSC code.
#
sub _LastSeen {
    my $self = shift;

    my $last = $self->{Response}->[-1];
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
            $self->{"CompCode"} == MQCC_OK &&
            $self->{"Reason"} == MQRC_NONE &&
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
        # So, what's going on here?  MQRCCF_CHL_STATUS_NOT_FOUND is
        # not really an error, per se.  It just means that there is no
        # available status information for that channel (i.e. its not
        # active).  So, we fake it...  We make the command appear to
        # have succeeded, and the feed back the status "NotFound".
        #
        if (
            $command eq 'InquireChannelStatus'  &&
            $self->{"Reason"} == MQRCCF_CHL_STATUS_NOT_FOUND
           ) {
            $response->{Parameters}->{ChannelStatus} = 'NotFound';
            $response->{Header}->{CompCode} = MQCC_OK;
            $response->{Header}->{Reason} = MQRC_NONE;
        }

    }

    return 1;

}


sub _ReverseMap {

    my $class = shift;
    my $ForwardKeyMap = shift;
    my $ReverseKeyMap = shift;

    foreach my $command ( keys %$ForwardKeyMap ) {
        #print "COMMAND: $command\n";

        my $ForwardCommandMap = $ForwardKeyMap->{$command};

        my $ForwardParameterMap = $ForwardCommandMap->[1];

        my $ReverseParameterMap = {};

        foreach my $parameter ( keys %$ForwardParameterMap ) {

            my $ForwardType = $ForwardParameterMap->{$parameter}->[1];
            my $ForwardValueMap = $ForwardParameterMap->{$parameter}->[2];

            if ( ref $ForwardValueMap eq 'HASH' ) {

                my $ReverseValueMap = {};

                foreach my $value ( keys %$ForwardValueMap ) {
                    if ($ForwardType == MQCFT_GROUP) {
                        #
                        # Groups have a $valuemap that's actually a
                        # regular map (for mapping the subparams) so
                        # we flip the key and primary value to produce
                        # almost the same, instead of just inverting
                        # the mapping.
                        #
                        $ReverseValueMap->{$ForwardValueMap->{$value}->[0]} =
                            [
                             $value,
                             $ForwardValueMap->{$value}->[2],
                            ];
                    }
                    else {
                        $ReverseValueMap->{$ForwardValueMap->{$value}} =
                            $value;
                    }
                }

                $ReverseParameterMap->{ $ForwardParameterMap->{$parameter}->[0] } =
                  [ $parameter, $ReverseValueMap ];

            } elsif (ref($ForwardValueMap) eq "CODE") {

                # VALUEMAP-CODEREF
                # This is "needed" for KeepAliveInterval value
                # handling, but isn't properly supported (yet) for
                # non-MQCFT_INTEGER types.
                $ReverseParameterMap->{ $ForwardParameterMap->{$parameter}->[0] } =
                  [ $parameter, $ForwardValueMap ];

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
