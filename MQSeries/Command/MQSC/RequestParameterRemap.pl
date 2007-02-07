#
# $Id: RequestParameterRemap.pl,v 27.1 2007/01/11 20:20:04 molinam Exp $
#
# (c) 1999-2007 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%RequestParameterRemap =
  (

   Queue =>
   {
    Key		=> 'QType',
    Values	=> $RequestValues{QType},
   },

  );

1;
