#
# $Id: Response.pm,v 24.1 2003/05/19 21:32:31 biersma Exp $
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
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

$VERSION = '1.21';

1;

