#
# $Id: XML-Dumper.pm,v 15.1 2000/08/16 00:59:02 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Message::XML-Dumper;

require 5.004;

use strict qw(vars refs);
use Carp;
use English;

use XML::Dumper;
use XML::Parser;

use MQSeries::Message;

use vars qw(@ISA $VERSION);

$VERSION = '1.12';
@ISA = qw(MQSeries::Message);

#
# NOTE: In 5.005 with -Dusethreads, $EVAL_ERROR is broken.
#

sub PutConvert {
    my $self = shift;
    my ($data) = @_;
    my $buffer = "";

    my $xml = XML::Dumper->new();
    eval { $buffer = $xml->pl2xml($data) };
    if ( $@ ) {
	$self->{Carp}->("Invalid data: XML::Dumper->pl2xml failed.\n" . $@);
	return undef;
    }
    else {
	return $buffer;
    }

}

sub GetConvert {
    my $self = shift;
    ($self->{Buffer}) = @_;
    my $data = "";
    my $parser = XML::Parser->new( Style => 'Tree' );
    my $dump = XML::Dumper->new();

    eval {
	my $tree = $parser->parse($self->{Buffer});
	$data = $dump->xml2pl($tree);
    };

    if ( $@ ) {
	$self->{Carp}->("Invalid buffer: XML::Dumper::xml2pl failed.\n" . $@);
	return undef;
    }
    else {
	return $data;
    }
}

1;

__END__

=head1 NAME

MQSeries::Message::XML-Dumper -- OO Class for sending and receiving perl references as MQSeries message application data in XML format, using the XML::Dumper module

=head1 SYNOPSIS

  use MQSeries::Message::XML-Dumper;
  my $message = MQSeries::Message::XML-Dumper->new
    (
     Data 		=> 
     {
      some 		=> "big ugly",
      complicated 	=>
      {
       data 		=> [0..5],
       structure 	=> [6..10],
      },
     },
    );


=head1 DESCRIPTION

This is a simple subclass of MQSeries::Message which support the use
of perl references as data structures in the message.  These
references have to be converted to a string of data which can be
written to an MQSeries message as application data, and for this the
XML::Dumper module is used.

=head1 METHODS

=head2 PutConvert, GetConvert

Neither of these methods are called by the users application, but are
used internally by MQSeries::Queue::Put() and MQSeries::Queue::Get(),
as well as MQSeries::QueueManager::Put1().

PutConvert() calls XML::Dumper::pl2xml to convert the perl reference
(which can be arbitrarily deep) to a scalar buffer which is then
passed to MQPUT() or MQPUT1().

GetConvert() calls XML::Dumper::xml2pl to convert the contents of a message
retreived from a queue via MQGET() to a perl reference, which is then
inserted into the Data structure of the message object.

=head1 SEE ALSO

MQSeries(3), MQSeries::QueueManager(3), MQSeries::Queue(3),
MQSeries::Message(3), XML::Dumper(3)

=cut
