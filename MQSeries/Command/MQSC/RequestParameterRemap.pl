#
# $Id: RequestParameterRemap.pl,v 33.3 2011/01/03 15:04:47 anbrown Exp $
#
# (c) 1999-2011 Morgan Stanley & Co. Incorporated
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
