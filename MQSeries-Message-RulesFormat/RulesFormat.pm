#
# $Id: RulesFormat.pm,v 11.1 1999/11/23 15:15:36 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Message::RulesFormat;

use strict;
use Carp;
use English;

use DynaLoader;
use Exporter;

use MQSeries;
use MQSeries::Message;

use vars qw( $VERSION @ISA @EXPORT_OK );

$VERSION = '1.08';

@ISA = qw( MQSeries::Message Exporter DynaLoader );

@EXPORT_OK = qw( MQDecodeRulesFormat MQEncodeRulesFormat );

bootstrap MQSeries::Message::RulesFormat;

sub new {

    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    my %MsgDesc = 
      (
       Format	=> MQFMT_RF_HEADER,
      );

    #
    # This is a bit wierd.  The MQSeries::Message->new() constructor
    # will deal with the Carp argument, however, we have to error
    # check the MsgDesc argument, and would like to use the
    # user-supplied Carp argument for consistent error handling.
    # Thus, this snippet looks very different from the other
    # classes...
    #
    if ( $args{Carp} ) {
	if ( ref $args{Carp} ne "CODE" ) {
	    carp "Invalid argument: 'Carp' must be a CODE reference\n";
	    return;
	}
    }
    else {
	$args{Carp} = \&carp;
    }

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

    if ( $args{Header} ) {
	$self->{Header} = $args{Header};
    }
    else {
	$self->{Header} = {};
    }

    if ( $args{Options} ) {
	$self->{Options} = $args{Options};
    }

    if ( $args{OptionsKeyPrefix} ) {
	$self->{OptionsKeyPrefix} = $args{OptionsKeyPrefix};
    }

    bless ($self, $class);

    return $self;

}

sub Options {
    my $self = shift;
    return $self->_OptionsHeader('Options',@_);
}

sub Header {
    my $self = shift;
    return $self->_OptionsHeader('Header',@_);
}

sub _OptionsHeader {

    my $self = shift;
    my $key = shift;

    if ( $_[0] ) {
	exists $self->{$key}->{$_[0]} ? return $self->{$key}->{$_[0]} : return;
    }
    else {
	return $self->{$key};
    }

}

sub GetConvert {

    my $self = shift;
    my ($buffer) = @_;
    my $data = "";
    my $options = "";

    unless ( ($self->{"Header"},$options,$data) = MQDecodeRulesFormat($buffer,length($buffer)) ) {
	$self->{Carp}->("Unable to decode MQSeries Rules and Format Message\n");
	return undef;
    } 

    unless ( $self->{"Options"} = $self->_DecodeOptions($options) ) {
	$self->{Carp}->("Unable to parse NameValueString from Rules and Format Message\n");
	return undef;
    }
      
    return $data;

}

sub PutConvert {

    my $self = shift;
    my ($data) = @_;

    my $options = $self->_EncodeOptions($self->{"Options"});
    return undef unless defined $options;

    my $buffer = MQEncodeRulesFormat($self->{"Header"},$options,length($options),$data,length($data));

    if ( $buffer ) {
	return $buffer;
    }
    else {
	$self->{Carp}->("Unable to encode MQSeries Rules and Format Message\n");
	return undef;
    }

}

sub _DecodeOptions {

    my $self = shift;
    my ($options) = @_;
    my (%options) = ();

    my $prefix = $self->{OptionsKeyPrefix} || "";

    while ( $options ) {
	
	my ($key,$value) = (undef,undef);

	if ( $options =~ s{
			   ^$prefix(\S+)
			   \s+
			   (
			    \"([^\"]|\"{2})+\"
			    |
			    \S+
			   )
			   [\s\0]*
			  }{}x ) {
	    ($key,$value) = ($1,$2);
	}

	unless ( defined $key && defined $value ) {
	    $self->{Carp}->("Unable to parse next key/value pair from options\n" . 
			    "Options => '$options'\n");
	    return undef;
	}

	#
	# Strip these *after* the above test, as "" is the only way to
	# specify an empty value.
	#
	$value =~ s/^\"//;
	$value =~ s/\"$//;

	#
	# Un-double quotify
	#
	$value =~ s/\"{2}/\"/g;

	#
	# If the key already exists, then it occurs multiple times, so
	# make the value into an ARRAY ref.
	#
	if ( exists $options{$key} ) {
	    if ( ref $options{$key} ne "ARRAY" ) {
		$options{$key} = [$options{$key}];
	    }
	    push(@{$options{$key}},$value);
	}
	else {
	    $options{$key} = $value;
	}
	
    }

    return {%options};

}

#
# All imbedded quotes must be doubled.  If they are already
# doubled, force them to single, and then double them all.
#
sub _EncodeOptions {

    my $self = shift;
    my @options = ();
    my $options = "";

    my $prefix = $self->{OptionsKeyPrefix} || "";

    my @keys;

    if ( $self->can("_OptionsKeySort") ) {
	@keys = $self->_OptionsKeySort();
    }
    else {
	@keys = keys %{$self->{"Options"}};
    }

    foreach my $key ( @keys ) {

	my $value = $self->{"Options"}->{$key};

	if ( ref $value eq "ARRAY" ) {
	    foreach my $subvalue ( @{$self->{"Options"}->{$key}} ) {
		# Need to *copy* the data, since foreach makes it a
		# reference to the actual data, which we want to leave
		# unmolested.
		my $newvalue = $subvalue;
		$newvalue =~ s/\"{2}/\"/g;
		$newvalue =~ s/\"/\"\"/g;
		if ( $newvalue =~ /\s/ ) {
		    push(@options,qq{$prefix$key "$newvalue"});
		}
		else {
		    push(@options,"$prefix$key $newvalue");
		}
	    }
	}
	else {
	    $value =~ s/\"{2}/\"/g;
	    $value =~ s/\"/\"\"/g;
	    if ( $value =~ /\s/ ) {
		push(@options,qq{$prefix$key "$value"});
	    }
	    else {
		push(@options,"$prefix$key $value");
	    }
	}

    }

    return join(" ",@options);

}

1;

__END__

=head1 NAME

MQSeries::Message::RulesFormat -- OO interface to the MQRFH Rules and Format message type

=head1 SYNOPSIS

  use MQSeries;
  use MQSeries::Message::RulesFormat;

=head1 DESCRIPTION

The MQSeries::Message::RulesFormat class is an interface to the Rules
and Formats message structure, used by both the MQSeries Integrator
1.x product and the Publish/Subscribe broker.  

=head1 METHODS

Since this class is a subclass of MQSeries::Message, all of the
latters methods are availables as well as the following:

=head2 new

The constructor takes all of the same key/value pairs as the
MQSeries::Message constructor, as well as the following additional keys:

  Key			Value
  ===			=====
  Header		HASH reference
  Options		HASH reference
  OptionsKeyPrefix	string

NOTE: The MsgDesc->Format string defaults to MQFMT_RF_HEADER
automatically, and should not be specified.  If it is overridden, then
in all likelyhood you may experience problems with the applications
(MQSI 1.x and the PubSub broker) that check the MQMD.Format.  This
should not be confused with the Header->Format, which specifies the
format of the application data which appears in the message after the
MQRFH structure.

=over 4

=item Header

The value of this key is a HASH reference representing the MQRFH
header structure.  See the docs for method of the same name below for
more information.

=item Options

The value of this key is a HASH reference representing the MQRFH
NameValue string.  See the docs for method of the same name below for
more information.

=item OptionsKeyPrefix

This species a fixed string which will prepended to all of the keys in
the Options HASH when the NameValue string is generated, and likewise
when the NameValue string is parsed, stripped.

This is used by MQSeries::PubSub::Message to strip the "MQPS" strings
from the NameValue string keys, to simplify the way the PubSub API is
coded.  This is, of course, the authors subjective opinion, but thats
why its fun to be the author.

=back

=head2 Header

This method returns the HASH reference representing the MQRFH
structure prepended to the NameValue string and application data in
the message body.  Note that this is B<NOT> the MQMD, which is
available via the standard MsgDesc method.

See the IBM documentation for the MQRFH structure for possible keys
and values.

Note that in general, this can be almost be entirely omitted, as the
default values for the MQRFH are usually sufficient.  The values which
a C or C++ application normally has to calculate, such as the
"StrucLength", are handled by the perl API automatically.

The only field that usually needs to be specified is the "Format".  If
the Data portion of the message is a string, then this must be set to
MQFMT_STRING, especially if character set conversion is expected to
work.

When returned, all of the structure fields are present as keys in the
HASH, with the exception of the "NameValueString" (which is not really
part of the C structure anyway), which is available via the Options
method.

=head2 Options

This method returns the HASH reference representing the data in the
NameValue string which is appended to the MQRFH structure.  The values
for each key are either a string for non-repeated keys, or an ARRAY
reference of strings for repeating fields.

For example, if the NameValue string in the MQRFH message was:

  Key1 Value1 Key2 ValueA Key2 ValueB Key3 Value3

then the decoded HASH reference will be:

  $options =
  {
   Key1		=> "Value1",
   Key2		=> [ "ValueA", "ValueB" ],
   key3		=> "Value3",
  }

Since the mapping is obviously reversible, the Options HASH passed to
the object constructor would have the same stucture as that shown
above.

=head1 SEE ALSO

MQSeries::Message(3), MQSeries::PubSub::Message(3)

=cut
