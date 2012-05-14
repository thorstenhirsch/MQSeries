#
# $Id: Response.pm,v 33.9 2011/01/03 15:04:49 anbrown Exp $
#
# (c) 1999-2011 Morgan Stanley & Co. Incorporated
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::Response;

use 5.008;

use strict;
use Carp;

use MQSeries::Command::Base;
use MQSeries::Message;

our @ISA = qw(MQSeries::Command::Base MQSeries::Message);
our $VERSION = '1.33';

1;

