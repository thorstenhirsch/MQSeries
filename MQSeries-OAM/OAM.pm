#
# $Id: OAM.pm,v 20.2 2002/03/18 20:33:20 biersma Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::OAM;

use strict;

use DynaLoader;
use Exporter;

use MQSeries qw(:functions);

use vars qw( $VERSION @ISA @EXPORT_OK );

$VERSION = '1.17';

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

