#
# $Id: Request.pm,v 9.7 1999/11/02 23:47:39 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::Request;

require 5.004;

use strict qw(vars refs);
use Carp;
use English;

use MQSeries;
use MQSeries::Command;
use MQSeries::Command::PCF;
use MQSeries::Command::MQSC;
use MQSeries::Message;
use MQSeries::Message::PCF qw(MQEncodePCF);

use vars qw(@ISA);

@ISA = qw(MQSeries::Message);

sub new {

    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    my %MsgDesc =
      (
       MsgType 	=> MQMT_REQUEST,
       Format 	=> $args{Type} eq 'MQSC' ? MQFMT_STRING : MQFMT_ADMIN,
      );

    if ( exists $args{MsgDesc} ) {
	unless ( ref $args{MsgDesc} eq "HASH" ) {
	    $args{Carp}->("Invalid argument: 'MsgDesc' must be a HASH reference.\n");
	    return;
	}	
	foreach my $key ( keys %{$args{MsgDesc}} ) {
	    $MsgDesc{$key} = $args{MsgDesc}->{$key};
	}
    }

    $args{MsgDesc} = {%MsgDesc};

    my $self = MQSeries::Message->new(%args) || return;

    #
    # What type of request is this?  PCF or MQSC?
    #
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
    # The Command argument is required:
    #
    if ( $args{Command} ) {
	if ( $self->{Type} eq 'PCF' ) {
	    unless ( exists $MQSeries::Command::PCF::Requests{$args{Command}} ) {
		$self->{Carp}->("Invalid command '$args{Command}'\n");
		return;
	    }
	}
	else {
	    unless ( exists $MQSeries::Command::MQSC::Requests{$args{Command}} ) {
		$self->{Carp}->("Invalid command '$args{Command}'\n");
		return;
	    }
	}
	$self->{Command} = $args{Command};
    }
    else {
	$self->{Carp}->("Required argument 'Command' is missing\n");
	return;
    }

    #
    # The RequestData argument is optional 
    #
    if ( $args{Parameters} ) {
	if ( ref $args{Parameters} eq 'HASH' ) {
	    $self->{Parameters} = $args{Parameters};
	}
	else {
	    $self->{Carp}->("Invalid argument: 'Parameters' must be a HASH reference");
	    return;
	}
    }
    else {
	$self->{Parameters} = {};
    }

    bless ($self, $class);

    return $self;

}

sub GetConvert {
    my $self = shift;
    $self->{Carp}->("MQGETing a MQSeries::Command::Request is not supported\n");
    return undef;
}

#
# Generate the message contents from the Request
#
sub PutConvert {

    my $self = shift;
    my $buffer = "";

    if ( $self->{Type} eq 'PCF' ) {
	my ($header,$parameters);
	unless ( ($header,$parameters) = $self->_TranslatePCF($self->{Command},$self->{Parameters}) ) {
	    $self->{Carp}->("Unable to translate Command/Parameters into MQEncodePCF input\n");
	    return;
	}
	$buffer = MQEncodePCF($header,$parameters);
    }
    else {
	$buffer = $self->MQEncodeMQSC($self->{Command},$self->{Parameters});
    }

    if ( $buffer ) {
	return $buffer;
    }
    else {
	$self->{Carp}->("Unable to encode MQSeries RequestHeader and Parameters\n");
	return undef;
    }

}

#
# This routine replaces something I originally did in C, using the
# perl internals API, to lookup all of these hashes and arrays.  
#
# Yes, I was insane...
#
sub _TranslatePCF {

    my $self = shift;
    my ($command,$origparams) = @_;

    my $header = { Type	=> MQCFT_COMMAND };
    my $parameters = [];

    my ($Requests,$RequestParameterRequired);

    unless ( $Requests = $MQSeries::Command::PCF::Requests{$command} ) {
	$self->{Carp}->("Unknown command '$command' " . 
			"not found in MQSeries::Command::PCF::Requests\n");
	return;
    }

    if ( exists $MQSeries::Command::PCF::RequestParameterRequired{$command} ) {
	$RequestParameterRequired = 
	  $MQSeries::Command::PCF::RequestParameterRequired{$command};
    }
    else {
	$RequestParameterRequired = {};
    }

    $header->{Command} = $Requests->[0];
    my $RequestParameters = $Requests->[1];

    foreach my $required ( 1, 0 ) {

	foreach my $origparam ( keys %$origparams ) {

	    unless ( 
		    ( $required == 1 && exists $RequestParameterRequired->{$origparam} )
		    ||
		    ( $required == 0 && not exists $RequestParameterRequired->{$origparam} )
		   ) {
		next;
	    }

	    my $origvalue = $origparams->{$origparam};

	    my ($paramkey,$paramtype,$RequestValues) = 
	      @{$RequestParameters->{$origparam}};

	    my $newparameter = 
	      {
	       Parameter	=> $paramkey,
	      };

	    #
	    # If the value passed is is an ARRAY, then make the
	    # parameter a string list (Strings).  If not, and the
	    # $paramtype requires a string list (MQCFT_STRING_LIST),
	    # then make the value into a single entry array.
	    #
	    if ( $paramtype == MQCFT_STRING || $paramtype == MQCFT_STRING_LIST ) {
		if ( ref $origvalue eq "ARRAY" ) {
		    $newparameter->{Strings} = $origvalue;
		}
		else {
		    if ( $paramtype == MQCFT_STRING_LIST ) {
			$newparameter->{Strings} = [$origvalue];
		    }
		    else {
			$newparameter->{String} = $origvalue;
		    }
		}
	    }

	    if ( $paramtype == MQCFT_INTEGER ) {
		if ( ref $RequestValues && exists $RequestValues->{$origvalue} ) {
		    $newparameter->{Value} = $RequestValues->{$origvalue};
		}
		else {
		    $newparameter->{Value} = $origvalue;
		}
	    }

	    if ( $paramtype == MQCFT_INTEGER_LIST ) {
		foreach my $value ( @$origvalue ) {
		    if ( ref $RequestValues && exists $RequestValues->{$value} ) {
			push(@{$newparameter->{Values}},$RequestValues->{$value});
		    }
		    else {
			push(@{$newparameter->{Values}},$value);
		    }
		}
	    }

	    push(@$parameters,$newparameter);

	}

    }

    return ($header,$parameters);

}

sub Command {
    my $self = shift;
    return $self->{Command};
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

sub MQEncodeMQSC {

    my $self = shift;
    my ($command,$parameters) = @_;
    my @buffer = ();
    my @parameters = ();
    my %skipparam = ();

    unless ( exists $MQSeries::Command::MQSC::Requests{$command} ) {
	$self->{Carp}->("No such MQSC command '$command'\n");
	return;
    }

    unless ( ref $MQSeries::Command::MQSC::Requests{$command} eq 'ARRAY' ) {
	$self->{Carp}->("PCF command '$command' not supported via MQSC\n");
	return;
    }

    my ($requestname,$requestparameters,$requestargs) =
      @{$MQSeries::Command::MQSC::Requests{$command}};

    push(@buffer,$requestname);

    my $foundattribute = 0;

    if ( $MQSeries::Command::MQSC::RequestParameterPrimary{$command} ) {
	@parameters = (
		       $MQSeries::Command::MQSC::RequestParameterPrimary{$command},
		       grep(
			    $_ ne $MQSeries::Command::MQSC::RequestParameterPrimary{$command},
			    keys %$parameters
			   )
		      );
    }
    else {
	@parameters = keys %$parameters;
    }

    foreach my $parameter ( @parameters ) {

	next if $skipparam{$parameter};

	unless ( $requestparameters->{$parameter} ) {
	    $self->{Carp}->("No such parameter '$parameter' for command '$command'\n");
	    return;
	}

	if ( ref $requestargs && not $requestargs->{$parameter} ) {
	    $foundattribute = 1;
	}

	my ($key,$type) = @{$requestparameters->{$parameter}};
	my $value = $parameters->{$parameter};

	if ( $key ) {

	    if ( ref $key eq 'HASH' ) {

		my ($subkey,$subvalues) = ($key->{Key},$key->{Values});

		unless ( $parameters->{$subkey} ) {
		    $self->{Carp}->("Require parameter '$subkey' for command '$command' missing\n");
		    return;
		}

		unless ( $subvalues->{$parameters->{$subkey}} ) {
		    $self->{Carp}->("Unknown value '$parameters->{$subkey}' for parameter '$subkey'\n");
		    return;
		}

		$key = $subvalues->{$parameters->{$subkey}};

		$skipparam{$subkey}++;
		
	    }

	    if ( $type eq 'integer' ) {
		push(@buffer,"$key($value)");
	    }
	    elsif ( $type eq 'string' ) {
		push(@buffer,"$key('$value')");
	    }
	    elsif ( ref $type eq 'ARRAY' ) {
		if ( $value ) {
		    push(@buffer,"$key($type->[1])");
		}
		else {
		    push(@buffer,"$key($type->[0])");
		}
	    }
	    elsif ( ref $type eq 'HASH' ) {
		push(@buffer,"$key($type->{$value})");
	    }
	    else {
		push(@buffer,$key);
	    }
	}
	else {
	    #
	    # Perform the specified key/value mapping of the data
	    #
	    if ( ref $type eq 'HASH' ) {
		if ( ref $value eq 'ARRAY' ) {
		    if ( scalar(@$value) ) {
			foreach my $string ( @$value ) {
			    unless ( $type->{$string} ) {
				$self->{Carp}->("Unknown value '$string' for parameter '$parameter'\n");
				return;
			    }
			    push(@buffer,$type->{$string});
			}	
		    }
		    else {
			# If the array is empty, we have to ignore this attribute
			$foundattribute = 0;
		    }
		}
		else {
		    unless ( $type->{$value} ) {
			$self->{Carp}->("Unknown value '$value' for parameter '$parameter'\n");
			return;
		    }
		    push(@buffer,$type->{$value});
		}
	    }
	    #
	    # Perform a boolean lookup of the value to map it to
	    # things like "NOREPLACE" or "REPLACE".
	    #
	    elsif ( ref $type eq 'ARRAY' ) {
		if ( $value ) {
		    push(@buffer,$type->[1]);
		}
		else {
		    push(@buffer,$type->[0]);
		}
	    }
	    #
	    # The data is either passed through as-is, or if an ARRAY
	    # is given, then the 'type' is the character to join the
	    # data with.
	    #
	    else {
		if ( ref $value eq "ARRAY" ) {
		    push(@buffer,join($type,@$value));
		}
		else {
		    push(@buffer,$value);
		}
	    }
	}

    }

    if ( ref $requestargs && $foundattribute == 0 ) {
	push(@buffer,"ALL");
    }

    return join(" ",@buffer);

}

1;

__END__

=head1 NAME

MQSeries::Command::Request -- OO Class for creating MQSeries Command messages

=head1 SYNOPSIS

  use MQSeries::Command::Request;
  my $request = MQSeries::Command::Request->new
    (
     Command => MQCMD_CHANGE_Q_MGR,
     Parameters =>
     {
      AuthorityEvent => MQEVR_ENABLED,
      InhibitEvent   => MQEVR_ENABLED,
     },
    );

=head1 DESCRIPTION

=head1 METHODS

=head2 PutConvert, GetConvert

Neither of these methods are called by the users application, but are
used internally by MQSeries::Queue::Put() and MQSeries::Queue::Get(),
as well as MQSeries::QueueManager::Put1().

The GetConvert method will cause a failure, since this class is only
to be used for decoding MQSeries events, not generating them.  Perhaps
a futute release will support the creation of such events.

The PutConvert method decodes the Command and Parameter into a valid
message format for the Command Server.

=head2 RequestHeader

This method can be used to query the RequestHeader data structure.  If
no argument is given, then the entire RequestHeader hash is returned.
If a single argument is given, then this is interpreted as a specific
key, and the value of that key in the RequestHeader hash is returned.

The keys in the RequestHeader hash are the fields from the MQCFH
structure.  See the "MQSeries Programmable System Management"
documentation.

=head2 Parameters

This method can be used to query the Parameters data structure.  If no
argument is given, then the entire Parameters hash is returned.  If a
single argument is given, then this is interpreted as a specific key,
and the value of that key in the Parameters hash is returned.

The keys in the Parameters hash vary, depending on the specific event.
In general, these are the strings shown in the documentation for each
individual event described in the "MQSeries Programmable System
Management" documentation.  The data structures in the eventdata in
the original event are identified with macros, such as
"MQCA_Q_MGR_NAME".  Rather than use these (in some cases very cryptic)
macros, the strings shown in the IBM MQSeries documentation are used
instead.  In this case, "QMgrName".

=head1 SEE ALSO

MQSeries(3), MQSeries::QueueManager(3), MQSeries::Queue(3),
MQSeries::Message(3)

=cut
