#
# $Id: OAM.pm,v 24.1 2003/05/19 21:32:09 biersma Exp $
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::OAM;

use strict;

use DynaLoader;
use Exporter;

use MQSeries qw(:functions);

use vars qw( $VERSION @ISA @EXPORT_OK );

$VERSION = '1.21';

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

