#
# $Id: MQSC.pm,v 12.1 2000/02/03 19:38:07 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

use vars qw($VERSION);

$VERSION = '1.09';

#
# Note -- the order is important, so resist the anal retentive urge to
# sort these lines in the interest of cosmetic appearance.
#
require "MQSeries/Command/MQSC/RequestValues.pl";
require "MQSeries/Command/MQSC/RequestParameterRemap.pl";
require "MQSeries/Command/MQSC/RequestParameterPrimary.pl";
require "MQSeries/Command/MQSC/RequestParameters.pl";
require "MQSeries/Command/MQSC/RequestArgs.pl";
require "MQSeries/Command/MQSC/Requests.pl";
require "MQSeries/Command/MQSC/ResponseValues.pl";
require "MQSeries/Command/MQSC/ResponseParameters.pl";
require "MQSeries/Command/MQSC/Responses.pl";

1;
