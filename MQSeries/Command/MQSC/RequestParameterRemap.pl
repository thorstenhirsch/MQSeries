#
# $Id: RequestParameterRemap.pl,v 25.1 2004/01/14 19:10:23 biersma Exp $
#
# (c) 1999-2004 Morgan Stanley Dean Witter and Co.
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
