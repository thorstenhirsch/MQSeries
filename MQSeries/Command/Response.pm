#
# $Id: Response.pm,v 33.7 2010/04/01 16:24:53 anbrown Exp $
#
# (c) 1999-2010 Morgan Stanley & Co. Incorporated
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::Response;

use 5.008;

use strict;
use Carp;

use MQSeries::Command::Base;
use MQSeries::Message;

our @ISA = qw(MQSeries::Command::Base MQSeries::Message);
our $VERSION = '1.32';

1;

