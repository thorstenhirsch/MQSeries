#
# $Id: PCF.pm,v 12.1 2000/02/03 19:38:38 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::PCF;

use vars qw($VERSION);

$VERSION = '1.09';

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
