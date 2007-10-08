#
# $Id: SpecialParameters.pl,v 30.1 2007/09/17 19:31:10 balusuv Exp $
#
# (c) 1999-2007 Morgan Stanley Dean Witter and Co.
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
