#
# $Id: OAM.pm,v 17.1 2001/03/14 00:19:47 wpm Exp $
#
# (c) 1999-2001 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::OAM;

use strict;

use DynaLoader;
use Exporter;

use MQSeries qw(:functions);

use vars qw( $VERSION @ISA @EXPORT_OK );

$VERSION = '1.14';

@ISA = qw( Exporter DynaLoader );

@EXPORT_OK = qw(
	       );

bootstrap MQSeries::OAM;

sub new {

    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    bless ($self, $class);
    return $self;

}

1;

__END__

=head1 NAME

MQSeries::OAM - 

=head1 SYNOPSIS



=head1 DESCRIPTION



=cut

