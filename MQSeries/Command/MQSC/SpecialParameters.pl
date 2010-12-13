#
# $Id: SpecialParameters.pl,v 33.2 2010/04/01 16:24:51 anbrown Exp $
#
# (c) 1999-2010 Morgan Stanley & Co. Incorporated
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%SpecialParameters =
  (

   #
   # These parameters are of type MQCFIL or MQCFSL and can have
   # more than one value defined ( , separated )
   # In Base.pm, we will convert the strings into arrays and 
   # vice versa
   #
   CompressionRate	=> [ "IntegerList" ],
   CompressionTime	=> [ "IntegerList" ],
   ExitTime		=> [ "IntegerList" ],
   HeaderCompression	=> [ "IntegerList" ],
   MessageCompression	=> [ "IntegerList" ],
   NetTime		=> [ "IntegerList" ],
   XQTime		=> [ "IntegerList" ],
 
  );

1;
