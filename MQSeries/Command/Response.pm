#
# $Id: Response.pm,v 26.1 2004/01/15 19:34:40 biersma Exp $
#
# (c) 1999-2004 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::Response;

require 5.005;

use strict;
use Carp;

use MQSeries::Command::Base;
use MQSeries::Message;

use vars qw(@ISA $VERSION);

@ISA = qw(
	  MQSeries::Command::Base
	  MQSeries::Message
	 );

$VERSION = '1.23';

1;

