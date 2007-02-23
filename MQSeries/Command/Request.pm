#
# $Id: Request.pm,v 28.2 2007/02/08 16:10:18 biersma Exp $
#
# (c) 1999-2007 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::Request;

use 5.006;

use strict;
use Carp;

use MQSeries::Command::Base;
use MQSeries::Message;

use vars qw(@ISA $VERSION);

@ISA = qw(
	  MQSeries::Command::Base
	  MQSeries::Message
	 );

$VERSION = '1.25';

1;


