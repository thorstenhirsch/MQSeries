#
# $Id: Storable.pm,v 17.1 2001/03/14 00:20:18 wpm Exp $
#
# (c) 1999-2001 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Message::Storable;

require 5.004;

use strict;
use Carp;

use Storable qw(nfreeze thaw);

use MQSeries::Message;

use vars qw(@ISA $VERSION);

$VERSION = '1.14';
@ISA = qw(MQSeries::Message);

#
# NOTE: In 5.005 with -Dusethreads, $EVAL_ERROR is broken.
#

sub PutConvert {
    my $self = shift;
    my ($data) = @_;
    eval { $self->{Buffer} = nfreeze($data); };
    if ( $@ ) {
	$self->{Carp}->("Invalid data: Storable::nfreeze failed.\n" . $@);
	return undef;
    }
    else {
	return $self->{Buffer};
    }

}

sub GetConvert {
    my $self = shift;
    ($self->{Buffer}) = @_;
    my $data = "";
    eval { $data = thaw($self->{Buffer}); };
    if ( $@ ) {
	$self->{Carp}->("Invalid buffer: Storable::thaw failed.\n" . $@);
	return undef;
    }
    else {
	return $data;
    }
}

1;

__END__

=head1 NAME

MQSeries::Message::Storable -- OO Class for sending and receiving perl references as MQSeries message application data

=head1 SYNOPSIS

  use MQSeries::Message::Storable;
  my $message = MQSeries::Message::Storable->new
    (
     Data => {
	      some => "big ugly",
	      complicated =>
	      {
	       data => [0..5],
	       structure => [6..10],
	      },
	     },
    );


=head1 DESCRIPTION

This is a simple subclass of MQSeries::Message which support the use
of perl references as data structures in the message.  These
references have to be converted to a string of data which can be
written to an MQSeries message as application data, and for this the
Storable module is used.

The Storable::nfreeze and Storable::thaw subroutines are not very
forgiving.  If the input to nfreeze is not a perl reference, then the
code raises a fatal exception.  Similarly, if the input to thaw is not
a frozen perl reference (i.e. the output from a nfreeze() call), is
also raises a fatal exception.  Both of these are trapped with eval,
but the data conversion is considered to fail, and thus the Put(),
Get(), or Put1() method calls will subsequently fail.

An object of this class will require that B<all> of the messages put
to or gotten from any given queue use perl references as the
underlying data structure.  This also requires that both the putting
and getting application use this class to create the MQSeries
messages.

=head1 METHODS

=head2 PutConvert, GetConvert

Neither of these methods are called by the users application, but are
used internally by MQSeries::Queue::Put() and MQSeries::Queue::Get(),
as well as MQSeries::QueueManager::Put1().

PutConvert() calls Storable::nfreeze to convert the perl reference
(which can be arbitrarily deep) to a scalar buffer which is then
passed to MQPUT() or MQPUT1().

GetConvert() calls Storable::thaw to convert the contents of a message
retreived from a queue via MQGET() to a perl reference, which is then
inserted into the Data structure of the message object.

=head1 SEE ALSO

MQSeries(3), MQSeries::QueueManager(3), MQSeries::Queue(3),
MQSeries::Message(3), Storable(3)

=cut
