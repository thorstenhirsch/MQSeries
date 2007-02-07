#
# $Id: OAM.pm,v 27.2 2007/01/11 20:19:59 molinam Exp $
#
# (c) 1999-2007 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::OAM;

use strict;

use DynaLoader;
use Exporter;

use MQSeries qw(:functions);

use vars qw( $VERSION @ISA @EXPORT_OK );

$VERSION = '1.24';

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

