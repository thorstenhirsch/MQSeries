#
# $Id: RequestParameterRemap.pl,v 16.1 2001/01/05 21:43:41 wpm Exp $
#
# (c) 1999-2001 Morgan Stanley Dean Witter and Co.
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
