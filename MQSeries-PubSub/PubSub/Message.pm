#
# $Id: Message.pm,v 10.1 1999/11/11 19:02:01 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::PubSub::Message;

require 5.004;

use strict;
use vars qw(
	    $VERSION
	    @ISA
	   );

use MQSeries::Message::RulesFormat;

$VERSION = '1.07';

@ISA = qw(MQSeries::Message::RulesFormat);

sub new {

    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = (  OptionsKeyPrefix => 'MQPS', @_ );

    my $self = MQSeries::Message::RulesFormat->new(%args) || return;

    bless ($self, $class);
    return $self;

}

#
# The "Command" key (which gets translated to MQPSCommand) must be the
# first option in the list.
#
sub _OptionsKeySort {
    my $self = shift;
    return ( 'Command', grep( $_ ne 'Command', keys %{$self->{Options}}) );
}

1;

__END__

=head1 NAME

MQSeries::PubSub::Message -- OO interface to the MQRFH based Publish/Subscribe message format

=head1 SYNOPSIS

  use MQSeries;
  use MQSeries::PubSub::Message;

=head1 DESCRIPTION

This class implements an OO interface to the MQRFH based
Publish/Subscribe message format, which is based on the Rules and
Format message type.  

=head1 METHODS

The MQSeries::PubSub::Message class is a subclass of the
MQSeries::Message::RulesFormat class, so all of the latters methods
are available.

=head2 new

The only notable difference between the MQSeries::PubSub::Message and
MQSeries::Message::RulesFormat constructors has to do with the
"OptionsKeyPrefix" argument.  

The MQSeries::PubSub::Message constructor calls the
MQSeries::Message::RulesFormat constructor with the additional
argument:

  OptionsKeyPrefix	=> 'MQPS',

Otherwise, the application supplied arguments are passed as-is to the
parent class constructor.  This argument tells the RulesFormat class
methods to prepend or strip the "MQPS" string from the Options keys,
when either encoding or decoding the MQRFH.NameValue string for the
raw message format.

This is is done to simplify the strings used in the application, as
documented in the MQSeries::PubSub::Command interface, and is entirely
cosmetic.  

Otherwise, these two classes are identical.

=head1 SEE ALSO

  MQSeries::PubSub::Broker(3),
  MQSeries::PubSub::Stream(3),
  MQSeries::PubSub::Command(3),
  MQSeries::Message::RulesFormat(3),

=cut
