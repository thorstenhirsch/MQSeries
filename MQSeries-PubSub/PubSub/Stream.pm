#
# $Id: Stream.pm,v 15.1 2000/08/16 00:41:21 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::PubSub::Stream;

use strict;
use Carp;
use English;

use MQSeries;
use MQSeries::QueueManager;
use MQSeries::Queue;
use MQSeries::PubSub::Command;

use vars qw( @ISA $VERSION );

@ISA = qw( MQSeries::PubSub::Command MQSeries::Queue );

$VERSION = '1.12';

sub Publish {
    my $self = shift;
    $self->_Command("Publish",@_);
}

sub DeletePublication {
    my $self = shift;
    $self->_Command("DeletePub",@_);
}

1;

__END__

=head1 NAME

MQSeries::PubSub::Stream -- OO Class for publishing data to an MQSeries Publish/Subscribe Stream

=head1 SYNOPSIS

See the documentation for MQSeries::PubSub::Command.

=head1 DESCRIPTION

See above.

=head1 SEE ALSO

MQSeries::PubSub::Command(3)

=cut
