#
# $Id: RequestParameterPrimary.pl,v 21.1 2002/06/21 16:04:52 biersma Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%RequestParameterPrimary =
  (

   #
   # Process commands
   #
   ChangeProcess		=> "ProcessName",
   CopyProcess			=> "ProcessName",
   CreateProcess		=> "ProcessName",
   DeleteProcess		=> "ProcessName",
   InquireProcess		=> "ProcessName",

   #
   # Queue commands
   #
   ChangeQueue			=> "QName",
   ClearQueue			=> "QName",
   CopyQueue			=> "ToQName",
   CreateQueue			=> "QName",
   DeleteQueue			=> "QName",
   InquireQueue			=> "QName",
   InquireQueueStatus           => "QName",
   ResetQueueStatistics         => "QName",

   #
   # Channel commands
   #
   ChangeChannel		=> "ChannelName",
   CopyChannel			=> "ChannelName",
   CreateChannel		=> "ChannelName",
   DeleteChannel		=> "ChannelName",
   InquireChannel		=> "ChannelName",
   InquireChannelStatus		=> "ChannelName",

   #
   # StorageClass commands
   #
   ChangeStorageClass		=> "StorageClassName",
   #CopyStorageClass		=> "StorageClassName",
   CreateStorageClass		=> "StorageClassName",
   DeleteStorageClass		=> "StorageClassName",
   InquireStorageClass		=> "StorageClassName",

  );

1;
