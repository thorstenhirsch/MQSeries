#
# $Id: PCF.pm,v 14.2 2000/08/15 20:51:43 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::PCF;

use vars qw($VERSION);

$VERSION = '1.11';

#
# Note -- the order is important, so resist the anal retentive urge to
# sort these lines in the interest of cosmetic appearance.
#
require "MQSeries/Command/PCF/RequestParameterRequired.pl";
require "MQSeries/Command/PCF/ErrorResponseParameters.pl";
require "MQSeries/Command/PCF/RequestValues.pl";
require "MQSeries/Command/PCF/RequestParameters.pl";
require "MQSeries/Command/PCF/Requests.pl";
require "MQSeries/Command/PCF/ResponseValues.pl";
require "MQSeries/Command/PCF/ResponseParameters.pl";
require "MQSeries/Command/PCF/Responses.pl";

1;
