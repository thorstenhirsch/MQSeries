#
# $Id: SpecialParameters.pl,v 33.1 2009/07/10 17:04:43 biersma Exp $
#
# (c) 1999-2009 Morgan Stanley & Co. Incorporated
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
