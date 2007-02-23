#
# MQSeries::Message::RFH2 - RFH2 Message
#
# (c) 2004-2007 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#
# $Id: RFH2.pm,v 28.1 2007/02/08 14:21:53 biersma Exp $
#

package MQSeries::Message::RFH2;

use strict;
use Carp;

use MQSeries::Message;
use vars qw(@ISA $VERSION);

$VERSION = '1.25';
@ISA = qw(MQSeries::Message);

#
# This describes the RFH2 structure.  We do this in perl to avoid XS
# code...
#
my @RFH_Struct =
  (
   #   	Name			Method		Length  Default
   [ qw(StrucId                 String		4	RFH	) ],
   [ qw(Version                 Number          4       2       ) ],
   [ qw(StrucLength             Number          4       36      ) ],
   [ qw(Encoding                Number          4),     MQSeries::MQENC_NATIVE ],
   [ qw(CodedCharSetId          Number          4       -2	) ],
   [ qw(Format                  String          8		) ],
   [ qw(Flags                   Number          4       0       ) ],
   [ qw(NameValueCCSID		Number		4	1208	) ],
);


#
# Constructor for an RFH2 message
#
# Hash with named parameters:
# - Data (in a non-standard format)
# - Header
# - Carp
#
sub new {
    my ($proto, %args) = @_;
    my $class = ref($proto) || $proto;

    my $carp = $args{Carp} || \&carp;
    die "Invalid 'Carp' parameter: not a code ref"
      unless (ref $carp eq 'CODE');

    my $this = MQSeries::Message->new(%args) || return;

    #
    # Deal with optional 'Header' parameter
    #
    $this->{Header} = $args{Header} || {};
    return bless $this, $class;
}


#
# Return header field / header hash reference
#
# One optional parameter: field name
#
sub Header {
    my ($this, $field) = @_;

    if (defined $field) {
        return $this->{Header}{$field}; # May be undef
    }
    return $this->{Header};
}


#
# Conversion routine on get: decode RFH into Header and Data
#
sub GetConvert {
    my ($this, $buffer) = @_;
    $this->_setEndianess();
    $this->{Buffer} = $buffer;

    my $offset = 0;

    foreach my $field (@RFH_Struct) {
        my ($key, $method, $length, $dft) = @$field;
        $method = "_read$method";
        if ($offset + $length > length($buffer)) {
            $this->{Carp}->("RFH field [$key] would read beyond buffer, stopping\n");
            $offset = length($buffer);
            last;
        }

        my $value = $this->$method($buffer, $offset, $length);
        #print "Read key [$key] value [$value]\n";
        $this->{Header}{$key} = $value;
        $offset += $length;
    }

    #
    # The RFH data is returned as a data length plus a string.
    #
    my $datalen = $this->_readNumber($buffer, $offset, 4);
    $offset += 4;
    my $data = $this->_readString($buffer, $offset, $datalen);
    return $data;
}


#
# Convert the data (XML-like string), plus an RFH2 Header, into an MQ
# message.
#
sub PutConvert {
    my ($this, $data) = @_;
    die "RFH2 data must be an XML-like string" if (ref $data);

    $this->_setEndianess();
    my $buffer = '';
    my $offset = 0;

    foreach my $field (@RFH_Struct) {
        my ($key, $method, $length, $dft) = @$field;
        $method = "_write$method";
        my $value = (defined $this->{Header}{$key} ?
                     $this->{Header}{$key} : $dft);
        substr($buffer, $offset, $length) = $this->$method($value, $length);
        $offset += $length;
    }

    #
    # The length of the data must be a multiple of four; round up
    # if required.
    #
    my $data_length = 4 * int((length($data) + 3)/ 4);
    substr($buffer, $offset, 4) = $this->_writeNumber($data_length);
    $offset += 4;

    substr($buffer, $offset, $data_length) = $this->_writeString($data);

    return $buffer;
}


# ------------------------------------------------------------------------

#-
# The globals determine how to pack numbers (big/little endian)
#
my ($packShort, $packNumber);

sub _readString {
    my $class = shift;
    my ($data,$offset,$length) = @_;
    return unpack("A*", substr($data,$offset,$length));
}


sub _writeString {
    my $class = shift;
    my ($string,$length) = @_;
    return $string . ( " " x ( $length - length($string) ) );
}


sub _readNumber {
    my $class = shift;
    my ($data,$offset,$length) = @_;
    return unpack($packNumber, substr($data,$offset,$length));
}


sub _writeNumber {
    my $class = shift;
    my ($number) = @_;
    return pack($packNumber, $number);
}


sub _readShort {
    my $class = shift;
    my ($data,$offset,$length) = @_;
    return unpack($packShort, substr($data,$offset,$length));
}


sub _writeShort {
    my $class = shift;
    my ($number) = @_;
    return pack($packShort, $number);
}


sub _readByte {
    my $class = shift;
    my ($data,$offset,$length) = @_;
    return substr($data,$offset,$length);
}


sub _writeByte {
    my $class = shift;
    my ($string,$length) = @_;
    if ( length($string) < $length ) {
	$string .= "\0" x ( $length - length($string) );
    }
    return $string;
}


#
# This sub is used to determine if the platform we are running on is
# Big/Little endian.  If the client platform and server platform have
# different endian-ness, you can invoke it with:
#
# - 0: server is little-endian (Linux/Intel, Windows NT)
# - 1: server is big-endian (Solaris/SPARC)
#
sub _setEndianess {
    my ($big_endian) = @_;

    if (@_ == 1) {
	return if (defined $packShort);
	#
	# Implicit invocation - base on guess work
	#
	$big_endian = pack('N', 1) eq pack('L', 1);
	#print STDERR "Implicitly set format to " . ($big_endian ? "big" : "little") . " endian\n";
    }

    if ($big_endian) {
	$packShort = "n";
	$packNumber= "N";
    } else {
	$packShort = "v";
	$packNumber= "V";
    }	
}

1;


__END__

=head1 NAME

MQSeries::Message::RFH2 -- Class to send/receive RFH2 messages

=head1 SYNOPSIS

  use MQSeries::Message::RFH2;

  #
  # Create an RFH2 message with default settings
  #
  my $msg = MQSeries::Message::RFH2->new('Data' => '<foo>bar</foo>');

  #
  # Same while overriding the Flags and NameValue character set id
  #
  my $msg2 = MQSeries::Message::RFH2->
    new('Header' => { 'NameValueCCSID' => 1200, # UCS-2
                      'Flags'          => 1,
                    },
        'Data'   => $ucs2_data);

  #
  # Get RFH2 data
  #
  my $queue = MQSeries::Queue->
    new(QueueManager => 'TEST.QM',
        Queue        => 'RFH2.DATA.QUEUE',
        Mode         => 'input');
  my $msg = MQSeries::Message::RFH2->new();
  $queue->Get(Message => $msg);
  my $data = $msg->Data();
  print "Have name-value data '$data'\n";

=head1 DESCRIPTION

This is a simple subclass of MQSeries::Message which supports sending
and retrieving RFH2 messages.  This class is experimental, as it was
based on the documentation and a few sample messages; feedback as to
how well it works is welcome.

An RFH2 message contains an RFH2 header, followed by a data string
with structured name-value data, in XML format.

=head1 METHODS

=head2 PutConvert, GetConvert

Neither of these methods are called by the users application, but are
used internally by MQSeries::Queue::Put() and MQSeries::Queue::Get(),
as well as MQSeries::QueueManager::Put1().

PutConvert() encodes the data supplied by the programmer into RFH2 format.

GetConvert() decodes the RFH2 header data and name-value pairs.
transaction name and body.

=head1 _setEndianess

An RFH2 message contains a number of numerical fields that are encoded
based on the endian-ness of the queue manager.  In most cases, that is
the same endian-ness as the client (certainly if both run on the same
machine), and this module uses that as the default.

If you need to override the guess made by this module, then you can
invoke the C<_setEndianess> method with 0 if server is little-endian
(Linux/Intel, Windows NT) and 1 if server is big-endian
(Solaris/SPARC).

For example, if you run on a Linux/Intel machine, but need to create a
message for a queue manager running on Solaris:

  MQSeries::Message::RFH2->_setEndianess(1);
  my $message = MQSeries::Message::RFH2->
    new('Data' => '<foo>bar</foo>');

=head1 AUTHORS

Hildo Biersma, Tim Kimber

=head1 SEE ALSO

MQSeries(3), MQSeries::QueueManager(3), MQSeries::Queue(3), MQSeries::Message(3)

=cut

