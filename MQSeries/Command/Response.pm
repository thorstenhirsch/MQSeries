#
# $Id: Response.pm,v 14.4 2000/08/15 20:51:46 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::Response;

require 5.004;

use strict qw(vars refs);
use Carp;
use English;

use MQSeries;
use MQSeries::Command;
use MQSeries::Command::PCF;
use MQSeries::Command::MQSC;
use MQSeries::Message;
use MQSeries::Message::PCF qw(MQDecodePCF);

use vars qw(@ISA $VERSION);

@ISA = qw(MQSeries::Message);

$VERSION = '1.11';

sub new {

    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    my $self = MQSeries::Message->new(%args) || return;

    if ( $args{Type} ) {
	unless ( $args{Type} eq 'PCF' or $args{Type} = 'MQSC' ) {
	    $self->{Carp}->("Invalid argument: 'Type' must be one of: PCF MQSC");
	    return;
	}
	$self->{Type} = $args{Type};
    }
    else {
	$self->{Type} = 'PCF';
    }

    #
    # When parsing MQSC message, the header is in a *seperate*
    # message, so we have to parse across several message at once.
    # We'll pass the header (a fake PCF header, sort of) to this
    # constructor after we've parsed the first message.  Yes, this is
    # gross...
    #
    if ( $args{Header} ) {
	$self->{Header} = $args{Header};
    }

    if ( $args{Parameters} ) {
	$self->{Parameters} = $args{Parameters};
    }

    bless ($self, $class);
    return $self;

}

#
# Generate the message contents from the Command
#
sub PutConvert {
    my $self = shift;
    $self->{Carp}->("MQPUTing a MQSeries::Command::Response is not supported\n");
    return undef;
}

sub GetConvert {
    my $self = shift;
    ($self->{Buffer}) = @_;

    my $header = {};

    if ( $self->{Type} eq 'PCF' ) {

	my ($header,$parameters);

	unless ( ($header,$parameters) = MQDecodePCF($self->{Buffer}) ) {
	    $self->{Carp}->("Unable to decode PCF buffer\n");
	    return undef;
	}

	unless ( ($self->{Header},$self->{Parameters}) = $self->_TranslatePCF($header,$parameters) ) {
	    $self->{Carp}->("Unable to translate Command/Parameters from MQDecodePCF output\n");
	    return undef;
	}

    }
    else {

	unless ( ($header,$self->{Parameters}) = $self->MQDecodeMQSC($self->{Header},$self->{Buffer}) ) {
	    $self->{Carp}->("Unable to parse MQSeries Command response from message\n");
	    return undef;
	}

	foreach my $key ( keys %$header ) {
	    if ( $key eq "ReasonText" ) {
		push(@{$self->{Header}->{$key}},$header->{$key});
	    }
	    else {
		$self->{Header}->{$key} = $header->{$key};
	    }
	}
	
    }

    return 1;

}

sub _TranslatePCF {

    my $self = shift;
    my ($origheader,$origparams) = @_;

    my $header = $origheader;

    my ($parameters);
    my ($Responses,$ResponseParameters);

    if ( $header->{"CompCode"} == MQCC_FAILED ) {
	$ResponseParameters = \%MQSeries::Command::PCF::ErrorsResponseParameters;
    }
    else {

	unless ( $Responses = $MQSeries::Command::PCF::Responses{$origheader->{Command}} ) {
	    $self->{Carp}->("Unknown command '$origheader->{Command}' " . 
			    "not found in MQSeries::Command::PCF::Requests\n");
	    return;
	}
	
	#
	# Actually, in the original XS code, we didn't translate the
	# command name from a number to a string. 
	#
	$header->{Command} = $Responses->[0];
	$ResponseParameters = $Responses->[1];

    }

    foreach my $origparam ( @$origparams ) {
	
	my ($newparameter,$newvalue,$ResponseValues);

	if ( exists $ResponseParameters->{$origparam->{Parameter}} ) {
	    ($newparameter,$ResponseValues) = @{$ResponseParameters->{$origparam->{Parameter}}};
	}
	else {
	    #
	    # XXX - Should we perhaps just let the unrecognized
	    # parameters pass through untranslated?  The XS code did
	    # this, but whined about them.
	    #
	    # $self->{Carp}->("Unknown parameter '$origparam->{Parameter}'\n");
	    $newparameter = $origparam->{Parameter};
	}

	#
	# The string types are trivial, since we just pass the strings
	# through unmolested (well, almost -- we strip trailing
	# whitespace), and only translate the parameter name to a
	# string (done above).
	#
	if ( $origparam->{Type} == MQCFT_STRING ) {
	    ( $parameters->{$newparameter} = $origparam->{String} ) =~ s/\s+$//;
	}

	if ( $origparam->{Type} == MQCFT_STRING_LIST ) {
	    foreach my $string ( @{$origparam->{Strings}} ) {
		$string =~ s/\s+$//;
		push(@{$parameters->{$newparameter}},$string);
	    }
	}

	#
	# For the integer types, we also have to translate (possibly)
	# the numeric values to strings as well.
	#
	if ( $origparam->{Type} == MQCFT_INTEGER ) {

	    if ( ref $ResponseValues eq "HASH" && exists $ResponseValues->{$origparam->{Value}} ) {
		$newvalue = $ResponseValues->{$origparam->{Value}};
	    }
	    else {
		$newvalue = $origparam->{Value};
	    }

	    $parameters->{$newparameter} = $newvalue;

	}

	if ( $origparam->{Type} == MQCFT_INTEGER_LIST ) {

	    my @newvalues;

	    foreach my $value ( @{$origparam->{Values}} ) {
		if ( ref $ResponseValues eq "HASH" && exists $ResponseValues->{$value} ) {
		    push(@newvalues,$ResponseValues->{$value});
		}
		else {
		    push(@newvalues,$value);
		}
	    }

	    $parameters->{$newparameter} = [@newvalues];

	}

    }


    return ($header,$parameters);

}

sub Command {
    my $self = shift;
    if ( ref $self->{Header} ) {
	return $self->{Header}->{Command};
    }
    else {
	return;
    }
}

sub CompCode {
    my $self = shift;
    if ( ref $self->{Header} ) {
	return $self->{Header}->{"CompCode"};
    }
    else {
	return;
    }
}

sub Reason {
    my $self = shift;
    if ( ref $self->{Header} ) {
	return $self->{Header}->{"Reason"};
    }
    else {
	return;
    }
}

sub ReasonText {

    my $self = shift;
    my $reasontext = "";

    if ( ref $self->{Header} ) {
	if ( exists $self->{Header}->{"ReasonText"} ) {
	    $reasontext = join("\n",@{$self->{Header}->{"ReasonText"}});
	}
	elsif ( exists $self->{Header}->{"Reason"} ) {
	    $reasontext = MQReasonToText($self->{Header}->{"Reason"});
	}
    }

    return $reasontext;
      
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

sub MQDecodeMQSC {

    my $self = shift;
    my ($oldheader,$buffer) = @_;

    my $command = $oldheader->{"Command"};
    my $newheader = {};
    my $parameters = {};

    #
    # OK, this is nothing short of obscene....
    #
    # If we have already seen ReasonText for this sequence of
    # messages, then we are just taking everything else and returning
    # it as reasontext.  This is because of the way MVS wraps the last
    # message into multiple lines, and then sends each line as a
    # seperate message.
    #
    if ( $oldheader->{"ReasonText"} ) {
	$newheader = { "ReasonText" => $buffer };
	return $newheader;
    }

    #
    # The easy part...
    #
    # The header is in a seperate message, so if we see one, we're
    # done.  There are no parameters, so just return the header.
    #
    if ( $buffer =~ m{
		      ^\S+\s+			# Message ID
		      COUNT=\s+(\d+),\s* 	# LastMsgSeqNumber
		      RETURN=(\w+),\s* 		# CompCode
		      REASON=(\w+) 		# Reason
		     }x ) {
	$newheader =
	  {
	   LastMsgSeqNumber	=> $1,
	   "CompCode"		=> $2,
	   "Reason"		=> $3,
	  };
	# This could be done in the regexp, with a bit of thought, I
	# suppose....
	$newheader->{"CompCode"} =~ s/0+(\d{1})$/$1/;
	$newheader->{"Reason"} =~ s/0+(\d{1})$/$1/;
	return $newheader;
    }

    #
    # Look for the error feedback...
    #
    if ( $buffer =~ m{
		      ^\S+\s+			# Message ID
		      \*\w+\s*			# The leading * is the key
		      (.*)
		     }x ) {
	$newheader =
	  {
	   "ReasonText"		=> $1,
	  };
	return $newheader;
    }

    #
    # Now things get hard...
    #
    unless ( $MQSeries::Command::MQSC::Responses{$command} ) {
	$self->{Carp}->("Unknown MQSC command '$command'\n");
	return;
    }

    my $responseparameters = $MQSeries::Command::MQSC::Responses{$command};
    
    #
    # Strip off the first message ID, label, whatever that is...
    #
    $buffer =~ s/^\S+\s+//;

    #
    # Strip off any trailing white noise, er, space
    #
    $buffer =~ s/\s+$//;
    
    #
    # This is used solely for debugging, since we strip $buffer to
    # nothing while parsing it.
    #
    my $origbuffer = $buffer;

    while ( $buffer ) {

	my ($key,$value,$realkey,$realvalue);
	my ($requestvalues);
	my $valuetype;

	if ( $buffer =~ s{
			  ^(\w+)	# keyword
			  \b(?!\()	# with NO following paren
			  \s*		# trailing whitespace
			 }{}x ) {
	    $key = $1;
	    $value = 1;
	    $valuetype = 'implicit';
	}
	#
	# ARGHH!!!  I hate this code.  Seriously....
	#
	# Special case for parsing "CONNAME(hostname(port))", which
	# has embedded parens in the TCP case.  This code gets more
	# vile, sick and obscene every time I touch it.  PCF is so
	# damn easy....
	#
	elsif ( $buffer =~ s{
			     ^(CONNAME)\(  	# Evil keyword with embedded parens
			     (			# the usual hostname(port) syntax
			      [^\(\)]+		#           hostname
			      \(		#                   (
			      [^\(\)]+		#                    port
			      \)		#                        )
			      [^\)]+		# everything that is not a closing paren
			     ) 	
			     \)\s* 		# close paren, and some whitespace
			    }{}x ) {
	    ($key,$value) = ($1,$2);
	    
	    # Extra whitespace is evil (well, at least really ugly)
	    $value =~ s/^\s+//;
	    $value =~ s/\s+$//;
	    $valuetype = 'explicit';
	}
	elsif ( $buffer =~ s{
			     ^(\w+)\( 	# keyword with open paren
			     ([^\)]+) 	# everything that is not a closing paren
			     \)\s* 	# close paren, and some whitespace
			    }{}x ) {
	    ($key,$value) = ($1,$2);
	    
	    # Extra whitespace is evil (well, at least really ugly)
	    $value =~ s/^\s+//;
	    $value =~ s/\s+$//;
	    $valuetype = 'explicit';
	}
	else {
	    $self->{Carp}->("Unrecognized MQSC buffer: $buffer\n");
	    last;
	}

	unless ( $responseparameters->{$key} ) {
	    $self->{Carp}->("Unrecognized parameter '$key' for command '$command'\n");
	    next;
	}

	($realkey,$requestvalues) = @{$responseparameters->{$key}};
	$realvalue = $value;

	# A null realkey means this is to be ignored
	next unless $realkey;

	if ( $valuetype eq 'explicit' ) {
	    if ( ref $requestvalues eq 'HASH' ) {
		unless ( exists $requestvalues->{$value} ) {
		    $self->{Carp}->("Unrecognized value '$value' for parameter '$realkey' for command '$command'\n");
		}
		else {
		    $realvalue = $requestvalues->{$value};
		}
	    }
	}
	else {
	    if ( $requestvalues and not ref $requestvalues) {
		$realvalue = $requestvalues;
	    }
	}

	$parameters->{$realkey} = $realvalue;
	
    }

    return ($newheader,$parameters);
    
}

1;

__END__

=head1 NAME

MQSeries::Command::Response -- OO Class for decoding MQSeries command server responses

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 PutConvert, GetConvert

=head1 SEE ALSO

MQSeries::Command(3)

=cut
