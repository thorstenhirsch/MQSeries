#
# $Id: Base.pm,v 20.4 2002/03/18 20:33:40 biersma Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::Base;

require 5.004;

use strict;
use Carp;

use MQSeries qw(:functions);
use MQSeries::Command;
use MQSeries::Command::PCF;
use MQSeries::Command::MQSC;
use MQSeries::Message;
use MQSeries::Message::PCF qw(MQEncodePCF MQDecodePCF);

use vars qw($VERSION);

$VERSION = '1.17';

sub new {

    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    my %MsgDesc =
      (
       MsgType 	=> $class =~ /::Request/ ? MQSeries::MQMT_REQUEST : MQSeries::MQMT_REPLY,
       Format 	=> $args{Type} eq 'MQSC' ? MQSeries::MQFMT_STRING : MQSeries::MQFMT_ADMIN,
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
    } else {
	$self->{Type} = 'PCF';
    }

    #
    # The Command argument is required... but now (1.12 and later) we
    # check this in PutConvert.
    #
    if ( $args{"Header"} ) {
	if ( ref $args{"Header"} eq 'HASH' ) {
	    $self->{"Header"} = $args{"Header"};
	    $self->{Command} = $self->{"Header"}->{Command}
	      if exists $self->{"Header"}->{Command};
	} else {
	    $self->{Carp}->("Invalid argument: 'Header' must be a HASH reference");
	    return;
	}
    }

    if ( $args{Command} ) {
	if ( $self->{Type} eq 'PCF' ) {
	    unless ( exists $MQSeries::Command::PCF::Requests{$args{Command}} ) {
		$self->{Carp}->("Invalid PCF command '$args{Command}'\n");
		return;
	    }
	} else {
	    unless ( exists $MQSeries::Command::MQSC::Requests{$args{Command}} ) {
		$self->{Carp}->("Invalid MQSC command '$args{Command}'\n");
		return;
	    }
	}
	$self->{Command} = $args{Command};
	$self->{"Header"}->{Command} = $args{Command};
    }

    #
    # The Parameters argument is optional
    #
    if ( $args{Parameters} ) {
	if ( ref $args{Parameters} eq 'HASH' ) {
	    $self->{Parameters} = $args{Parameters};
	} else {
	    $self->{Carp}->("Invalid argument: 'Parameters' must be a HASH reference");
	    return;
	}
    } else {
	$self->{Parameters} = {};
    }

    #
    # Do we want strict mapping turned on?
    #
    if ( exists $args{StrictMapping} ) {
	$self->{StrictMapping} = $args{StrictMapping};
    }

    bless ($self, $class);

    return $self;

}


#
# This routine replaces something I originally did in C, using the
# perl internals API, to lookup all of these hashes and arrays.
#
# Yes, I was insane...
#
sub _TranslatePCF {
    my ($self, $header, $origparams) = @_;

    my $command = $header->{Command};

    ($header->{Type}) = ( $self->isa("MQSeries::Command::Response") ?
			  MQSeries::MQCFT_RESPONSE :
			  MQSeries::MQCFT_COMMAND );

    my $parameters = [];

    my ($ForwardMap) = ( $self->isa("MQSeries::Command::Response") ?
		         \%MQSeries::Command::PCF::Responses :
			 \%MQSeries::Command::PCF::Requests );

    my ($RequiredMap) = ( $self->isa("MQSeries::Command::Response") ?
			  {} :
			  \%MQSeries::Command::PCF::RequestParameterRequired );

    #
    # Special handling for error responses.
    #
    my $CommandMap = $ForwardMap->{$command} || do {
	$self->{Carp}->("Unknown command '$command'");
	return;
    };

    $header->{Command} = $CommandMap->[0];

    my ($ParameterMap) = ( $header->{CompCode} ?
			   $ForwardMap->{Error}->[1] :
			   $CommandMap->[1] );

    my ($ParameterRequired) = ( exists $RequiredMap->{$command} ?
				$RequiredMap->{$command} :
				{} );
    my @required_order = sort { $ParameterRequired->{$a} <=> 
                                $ParameterRequired->{$b}
                              } keys %$ParameterRequired;
    my $ParameterOrderList = $MQSeries::Command::PCF::RequestParameterOrder{$command};
    my @optional_order = ($ParameterOrderList ? @$ParameterOrderList : ());

    my %ParameterOrderHash = map { ($_,1) } (@required_order, @optional_order);

    #
    # Verify that all of the parameters are known - this finds my typos...
    #
    {
	my $unknown = 0;
	foreach my $param (keys %$origparams) {
	    next if (defined $ParameterMap->{$param});
	    $self->{'Carp'}->("Unknown parameter '$param' for command '$command'");
	    $unknown++;
	}
	return if $unknown;
    }

    #
    # Verify that all of the required parameters have been given.
    #
    {
	my $required = 0;
	foreach my $param ( keys %$ParameterRequired ) {
	    next if (defined $origparams->{$param});
	    $self->{Carp}->("Required parameter '$param' not specified for command '$command'");
	    $required++;
	}
	return if $required;
    }

    #
    # Sort the parameters, required then optional, and if necessary,
    # command dependent order.
    #
    my @ordered_params = ();
    foreach my $pair ( [ 'Required', \@required_order ],
                       [ 'Optional', \@optional_order ] ) {
        my ($type, $list) = @$pair;

	foreach my $param (@$list) {
	    next unless defined $origparams->{$param};
	    push @ordered_params, $param;
	}

	foreach my $param (keys %$origparams) {
	    next if ($type eq 'Required' && 
                     not exists $ParameterRequired->{$param});
	    next if ($type eq 'Optional' && 
                     exists $ParameterRequired->{$param});
	    push @ordered_params, $param 
              unless $ParameterOrderHash{$param};
	}

    }

    foreach my $param (@ordered_params) {
	my $origvalue = $origparams->{$param};

	my ($paramkey,$paramtype,$ValueMap) = @{ $ParameterMap->{$param} };

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
	# NOTE: We forcibly quote the values to force them into
	# strings, otherwise SvPOK() will complain about integers,
	# which can of course be represented as strings.  This
	# might just be a bad choice on my part in the XS code.
	#
	if ( $paramtype == MQSeries::MQCFT_STRING || 
             $paramtype == MQSeries::MQCFT_STRING_LIST ) {
	    if ( ref $origvalue eq "ARRAY" ) {
		$newparameter->{Strings} = [];
		foreach my $value ( @$origvalue ) {
		    my $newvalue = length($value) == 0 ? " " : "$value";
		    push(@{$newparameter->{Strings}},"$newvalue");
		}
	    } else {
		my $newvalue = length($origvalue) == 0 ? " " : "$origvalue";
		if ( $paramtype == MQSeries::MQCFT_STRING_LIST ) {
		    $newparameter->{Strings} = ["$newvalue"];
		} else {
		    $newparameter->{String} = "$newvalue";
		}
	    }
	}

	if ( $paramtype == MQSeries::MQCFT_INTEGER ) {
	    if ( ref $ValueMap ) {
		unless ( exists $ValueMap->{$origvalue} ) {
		    $self->{Carp}->("Unknown value '$origvalue' for " .
				    "parameter '$param', command '$command'");
		    return;
		}
		$newparameter->{Value} = $ValueMap->{$origvalue};
	    } else {
		$newparameter->{Value} = $origvalue;
	    }
	}

	if ( $paramtype == MQSeries::MQCFT_INTEGER_LIST ) {
	    foreach my $value ( @$origvalue ) {
		if ( ref $ValueMap ) {
		    unless ( exists $ValueMap->{$value} ) {
			$self->{Carp}->("Unknown value '$origvalue' for " .
					"parameter '$param', command '$command'");
			return;
		    }
		    push(@{$newparameter->{Values}},$ValueMap->{$value});
		} else {
		    push(@{$newparameter->{Values}},$value);
		}
	    }
	}

	push(@$parameters,$newparameter);
    }

    return ($header,$parameters);
}


#
# This routine does the reverse mapping of _TranslatePCF.
#
sub _UnTranslatePCF {

    my $self = shift;

    my ($header,$origparams) = @_;

    my $command = $header->{Command};

    my $parameters = {};

    my ($ReverseMap) = ( $self->isa("MQSeries::Command::Response") ?
		         \%MQSeries::Command::PCF::_Responses :
			 \%MQSeries::Command::PCF::_Requests );

    my $CommandMap = $ReverseMap->{$command} || do {
	$self->{Carp}->("Unknown command '$command'");
	return;
    };

    $header->{Command} = $CommandMap->[0];

    my $ParameterMap = ( $header->{CompCode} ?
			 $ReverseMap->{Error}->[1] :
			 $CommandMap->[1] );

    foreach my $origparam ( @$origparams ) {

	my $paramkey = $ParameterMap->{$origparam->{Parameter}}->[0];
	my $paramvalue = "";

	if ( exists $origparam->{String} ) {
	    ( $parameters->{$paramkey} = $origparam->{String} ) =~ s/\s+$//;
	    next;
	} elsif ( exists $origparam->{Strings} ) {
	    foreach my $string ( @{$origparam->{Strings}} ) {
		$string =~ s/\s+$//;
		push(@{$parameters->{$paramkey}},$string);
	    }
	    next;
	} elsif ( exists $origparam->{Value} ) {
	    $paramvalue = $origparam->{Value};
	} elsif ( exists $origparam->{Values} ) {
	    $paramvalue = $origparam->{Values};
	} else {
	    # Uh...  MQDecodePCF shouldn't ever let this happen...
	    $self->{Carp}->("Unable to map parameter '$paramkey'\n");
	    return;
	}

	my $ValueMap = $ParameterMap->{$origparam->{Parameter}}->[1] || do {
	    $parameters->{$paramkey} = $paramvalue;
	    next;
	};

	if ( ref $paramvalue eq 'ARRAY' ) {
	    my $newvalue = [];
	    foreach my $value ( @$paramvalue ) {
		if ( exists $ValueMap->{$value} ) {
		    push(@$newvalue,$ValueMap->{$value});
		} elsif ( $self->{StrictMapping} ) {
		    $self->{Carp}->("Unable to map value of '$value' for parameter '$paramkey'");
		    return;
		} else {
		    push(@$newvalue,$value);
		}
	    }
	    $parameters->{$paramkey} = $newvalue;
	} else {
	    if ( exists $ValueMap->{$paramvalue} ) {
		$parameters->{$paramkey} = $ValueMap->{$paramvalue};
	    } elsif ( $self->{StrictMapping} ) {
		$self->{Carp}->("Unable to map value of '$paramvalue' for parameter '$paramkey'");
		return;
	    } else {
		$parameters->{$paramkey} = $paramvalue;
	    }
	}

    }

    return ($header,$parameters);

}

sub GetConvert {

    my $self = shift;
    ($self->{Buffer}) = @_;

    my ($header,$parameters);

    if ( $self->{Type} eq 'PCF' ) {

	($header,$parameters) = MQDecodePCF($self->{Buffer}) or do {
	    $self->{Carp}->("Unable to decode PCF buffer\n");
	    return undef;
	};

	($self->{"Header"},$self->{Parameters}) = $self->_UnTranslatePCF($header,$parameters) or do {
	    $self->{Carp}->("Unable to translate Command/Parameters from MQDecodePCF output\n");
	    return undef;
	};

    } else {

	if ( $self->isa("MQSeries::Command::Request") ) {

	    $self->{Carp}->("MQGETing a MQSeries::Command::Request is not supported for type MQSC\n");
	    return undef;

	} else {

	    ($header,$self->{Parameters}) = $self->MQDecodeMQSC($self->{"Header"},$self->{Buffer}) or do {
		$self->{Carp}->("Unable to parse MQSeries Command response from message\n");
		return undef;
	    };

	    foreach my $key ( keys %$header ) {
		if ( $key eq "ReasonText" ) {
		    push(@{$self->{"Header"}->{$key}},$header->{$key});
		} else {
		    $self->{"Header"}->{$key} = $header->{$key};
		}
	    }
	
	}

    }

    return 1;

}

sub PutConvert {

    my $self = shift;

    unless ( $self->{Command} ) {
	$self->{Carp}->("Required argument 'Command' is missing\n");
	return undef;
    }

    if ( $self->{Type} eq 'PCF' ) {
	my ($header,$parameters) = $self->_TranslatePCF($self->{Header},$self->{Parameters}) or do {
	    $self->{Carp}->("Unable to translate Command/Parameters into MQEncodePCF input\n");
	    return undef;
	};
	$self->{Buffer} = MQEncodePCF($header,$parameters);
    } else {
	if ( $self->isa("MQSeries::Command::Response") ) {
	    $self->{Carp}->("MQPUTing a MQSeries::Command::Response is not supported for type MQSC\n");
	    return undef;
	} else {
	    $self->{Buffer} = $self->MQEncodeMQSC($self->{Command},$self->{Parameters});
	}
    }

    if ( $self->{Buffer} ) {
	return $self->{Buffer};
    } else {
	$self->{Carp}->("Unable to encode MQSeries Request Header and Parameters\n");
	return undef;
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
    } else {
	return $self->{Parameters};
    }

}

sub Header {

    my $self = shift;

    unless (
	    ref $self->{"Header"} eq 'HASH' and
	    keys %{$self->{"Header"}}
	   ) {
	return;
    }

    if ( $_[0] ) {
	return $self->{"Header"}->{$_[0]};
    } else {
	return $self->{"Header"};
    }

}

sub Command {
    my $self = shift;
    if ( $self->{Command} ) {
	return $self->{Command};
    } elsif ( ref $self->{"Header"} ) {
	return $self->{"Header"}->{Command};
    } else {
	return;
    }
}

sub CompCode {
    my $self = shift;
    if ( ref $self->{"Header"} ) {
	return $self->{"Header"}->{"CompCode"};
    } else {
	return;
    }
}

sub Reason {
    my $self = shift;
    if ( ref $self->{"Header"} ) {
	return $self->{"Header"}->{"Reason"};
    } else {
	return;
    }
}

sub ReasonText {

    my $self = shift;
    my $reasontext = "";

    if ( ref $self->{"Header"} ) {
	if ( exists $self->{"Header"}->{"ReasonText"} ) {
	    $reasontext = join("\n",@{$self->{"Header"}->{"ReasonText"}});
	} elsif ( exists $self->{"Header"}->{"Reason"} ) {
	    $reasontext = MQReasonToText($self->{"Header"}->{"Reason"});
	}
    }

    return $reasontext;

}


sub MQEncodeMQSC {
    my ($self, $command, $parameters) = @_;
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

    my ($requestname, $requestparameters, $requestargs) =
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
    } else {
	@parameters = keys %$parameters;
    }

    foreach my $parameter ( @parameters ) {
	next if $skipparam{$parameter};

	unless (defined $requestparameters->{$parameter} ) {
	    $self->{Carp}->("No such request parameter '$parameter' for command '$command'\n");
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
		    $self->{Carp}->("Required parameter '$subkey' for command '$command' missing\n");
		    return;
		}

		unless (defined $subvalues->{$parameters->{$subkey}} ) {
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
	} else {
	    #
	    # Perform the specified key/value mapping of the data
	    #
	    if ( ref $type eq 'HASH' ) {
		if ( ref $value eq 'ARRAY' ) {
		    if ( scalar(@$value) ) {
			foreach my $string ( @$value ) {
			    unless (defined $type->{$string} ) {
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


sub MQDecodeMQSC {
    my $self = shift;
    my ($oldheader,$buffer) = @_;

    my $command = $oldheader->{"Command"};
    # XXX - I think we should be initializing this to the oldheader
    my $newheader = $oldheader;
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
		      ^CSQN\S+\s+               # Message ID
		      COUNT=\s+(\d+),\s* 	# LastMsgSeqNumber
		      RETURN=(\w+),\s* 		# CompCode
		      REASON=(\w+) 		# Reason
		     }x ) {
	$newheader =
	  {
	   "LastMsgSeqNumber"	=> $1,
	   "CompCode"		=> eval "0x$2",
	   "Reason"		=> eval "0x$3",
	  };
	return $newheader;
    }

    #
    # Look for the error feedback...
    #
    # We recognize this because:
    # - The message looks like CSQxxxxx *XYZZY or CSQxxxx /XYZZY
    # - The message code is not CSQM4xxI, which is the normal message
    #   return
    #
    # NOTE: In MQ 5.2 for OS/390, the *XYZZY occurs in CSQM409I, but this
    #       did not occur in previous version.  Hence, we have to take
    #       care not to assume any *XYZZY or /XYYZY is an error.
    #
    if ( $buffer =~ m{
		      ^(?!CSQM4\d\dI)\S+\s+	# Message ID
		      [\*/]\w+\s*               # The leading * or / is the key
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
    # In MQ 5.2 for OS/390, there is also a leading *<QMgrName>
    # at the start of the buffer, so we strip that off here.
    #
    $buffer =~ s!^\*\S+\s+!!;

    #
    # This is used solely for debugging, since we strip $buffer to
    # nothing while parsing it.
    #
    my $origbuffer = $buffer;

    while ( $buffer ) {

	my ($key,$value,$realkey,$realvalue);
	my ($requestvalues);
	my $valuetype;

	#
	# XXX -- MQSeries V2.2 on OS/390 changes the text returned by
	# the command server.  In 2.1 and earlier, the messages look
	# like:
	#
	#   CSQM409I   QMNAME(CSQ1 .....
	#
	# but now there is an extra field:
	#
	#   CSQM409I ]QMH1 QMNAME(QMH1
	#
	# So, as of 1.12, we'll accept bare keywords that are any
	# non-whitespace, and then just let the bogus tag be ignored.
	#
	# Did I mention I hate this code yet? -- wpm, 8/18/2000
	#
	if ( $buffer =~ s{
			  ^([\w\]]+) 		# keyword
			  \b(?!\() 		# with NO following paren
			  \s*			# trailing whitespace
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
			     ^(CONNAME)\( 	# Evil keyword with embedded parens
			     (			# the usual hostname(port) syntax
			      [^\(\)]+ 		#           hostname
			      \( 		#                   (
			      [^\(\)]+ 		#                    port
			      \) 		#                        )
			      [^\)]+ 		# everything that is not a closing paren
			     )	
			     \)\s* 		# close paren, and some whitespace
			    }{}x ) {

	    ($key,$value) = ($1,$2);

	    # Extra whitespace is evil (well, at least really ugly)
	    $value =~ s/^\s+//;
	    $value =~ s/\s+$//;
	    $valuetype = 'explicit';

	} elsif ( $buffer =~ s{
			       ^(\w+)\(		# keyword with open paren
			       ([^\)]*)		# everything that is not a closing paren
			       \)\s* 		# close paren, and some whitespace
			      }{}x ) {

	    ($key,$value) = ($1,$2);

	    # Extra whitespace is evil (well, at least really ugly)
	    $value =~ s/^\s+//;
	    $value =~ s/\s+$//;
	    $valuetype = 'explicit';

	} else {
	    $self->{Carp}->("Unrecognized MQSC buffer: $buffer\n");
	    last;
	}

	unless ( $responseparameters->{$key} ) {
	    $self->{Carp}->("Unrecognized response parameter '$key' for command '$command'\n");
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
		} else {
		    $realvalue = $requestvalues->{$value};
		}
	    }
	} else {
	    if (defined $requestvalues and not ref $requestvalues) {
		$realvalue = $requestvalues;
	    }
	}

	$parameters->{$realkey} = $realvalue;
    }

    return ($newheader,$parameters);

}

1;