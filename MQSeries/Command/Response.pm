#
# $Id: Response.pm,v 22.1 2002/07/23 20:27:28 biersma Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
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

$VERSION = '1.19';

1;

