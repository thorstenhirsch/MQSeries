#
# $Id: Response.pm,v 15.3 2000/10/24 01:09:26 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::Response;

require 5.004;

use strict qw(vars refs);
use Carp;
use English;

use MQSeries::Command::Base;
use MQSeries::Message;

use vars qw(@ISA $VERSION);

@ISA = qw(
	  MQSeries::Command::Base
	  MQSeries::Message
	 );

$VERSION = '1.12';

1;

