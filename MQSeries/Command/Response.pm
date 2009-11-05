#
# $Id: Response.pm,v 33.2 2009/07/10 18:28:59 biersma Exp $
#
# (c) 1999-2009 Morgan Stanley & Co. Incorporated
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::Response;

use 5.008;

use strict;
use Carp;

use MQSeries::Command::Base;
use MQSeries::Message;

our @ISA = qw(MQSeries::Command::Base MQSeries::Message);
our $VERSION = '1.30';

1;

