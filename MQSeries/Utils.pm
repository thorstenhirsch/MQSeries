#
# $Id: Utils.pm,v 23.2 2003/04/10 19:10:21 biersma Exp $
#
# (c) 2000-2003 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Utils;

require 5.005;

use strict;
use Carp;

use Exporter;
use vars qw(@ISA @EXPORT_OK $VERSION);
@ISA = qw(Exporter);
@EXPORT_OK = qw(ConvertUnit VerifyNamedParams);
$VERSION = '1.20';

#
# Convert a Unit value from a symbolic value to the value
# that MQ expects.
#
# Parameters:
# - Name: 'Wait' / 'Expiry'
# - Value: number / number + 's' for seconds / number + 'm' for minutes
# Returns:
# - Numeric value
#
sub ConvertUnit {
    my ($name, $value) = @_;

    my $numeric_patt = '(?:-?[\d_.]+)';
    if ($name eq 'Wait' || $name eq 'Expiry') {
        #
        # Wait is in milli-seconds, Expiry in tenths of a second
        #
        my $scale = ($name eq 'Wait' ? 1000 : 10);
        if ($value =~ m!^$numeric_patt$!) { 
            # Nothing to be done
        } elsif ($value =~ m!^($numeric_patt)s$!) {
            # Times <scale>
            $value = $1 * $scale;
        } elsif ($value =~ m!^($numeric_patt)m$!) {
            # Times 60 * <scale>
            $value = $1 * 60 * $scale;
        } else {
            die "Invalid '$name' value '$value'";
        }
    } else {
        die "Unsupported unit '$name'";
    }
    return $value;
}


#
# Helper function: Verify named subroutine parameters
# 
# Parameters:
# - Ref to parameter hash
# - Ref to array of required parameters
# - Ref to array of optional parameters
#
sub VerifyNamedParams ($$;$) {
    my ($params, $required, $optional) = @_;
    $required ||= [];
    $optional ||= [];

    my @errors;
    my %args = %$params;
    foreach my $par (@$required) {
        my $value = delete $args{$par};
        if (defined $value) {
            if ($par eq 'Carp') {
                unless (ref($value) eq 'CODE') {
                    push @errors, "Invalid '$par' value '$value': not a code-reference";
                }
            } 
        } else {
            push @errors, "Required parameter '$par' missing";
        }
    }
    delete @args{@$optional};
    foreach my $par (sort keys %args) {
        push @errors, "Invalid parameter '$par'";
    }
    return unless (@errors);
    
    my ($package, $filename, $line, $subroutine) = caller(1);
    unshift @errors, "Illegal parameters for subroutine [$subroutine] at [$filename] line [$line]";
    confess join("\n", @errors);
}



1;


__END__

=head1 NAME

MQSeries::Utils - Internal utility functions

=head1 SYNOPSIS

  use MQSeries::Utils qw(ConvertUnit);

  my $wait_value = ConvertUnit('Wait', '45s');
  my $exp_value = ConvertUnit('Expiry', '1.5m');

=head1 DESCRIPTION

The MQSeries::Utils module contains internal helper functions that are
generally not of interest to users of the MQSeries module.

=head1 FUNCTIONS

=head2 ConvertUnit

This function can convert values for the 'Wait' and 'Expiry' options
from symbolic values into the numeric values required. Symbolic values
are numeric values ending in an 's' for seconds or an 'm' for minutes.

As 'Wait' values are in 1/1000 of a second and 'Expiry' is in 1/10 of
a second, using symbolic values can help avoid mistakes such as
getting the magnitude of these numbers wrong by one or more orders of
magnitude.

=head2 VerifyNamedParams

Helper function to verify the named parameters received by other
subroutines or methods.  If a function uses the hash-like named
parameter convention, it can call VerifyNamedParams to verify that all
required parameters are present and that no unknown parameters have
been specified.  If anything is incorrect, a detailed error trace will
be printed and the program will be terminated.  This function is
extremely useful during development, especially when APIs change.

This function takes two required and one optional parameters, all
positional:

=over 4

=item Params

A reference to the subroutine parameters received

=item Required

A reference to an array of required parameter names. These must be
present and defined.  If the parameter name is C<Carp>, the value must
be a code reference.

=item Optional

An optional reference to an array of optional parameter names. These
may be present, be 'undef', or may be missing.  The types will not be
checked.

=back

=head1 SEE ALSO

MQSeries(3)

=cut
