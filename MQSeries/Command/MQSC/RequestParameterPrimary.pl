#
# $Id: RequestParameterPrimary.pl,v 25.1 2004/01/14 19:10:23 biersma Exp $
#
# (c) 1999-2004 Morgan Stanley Dean Witter and Co.
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

   #
   # AuthInfo commands
   #
   ChangeAuthInfo		=> "AuthInfoName",
   CopyAuthInfo			=> "AuthInfoName",
   CreateAuthInfo		=> "AuthInfoName",
   DeleteAuthInfo		=> "AuthInfoName",
   InquireAuthInfo		=> "AuthInfoName",

   #
   # Coupling Facility Structure commands
   #
   ChangeCFStruct		=> "CFStructName",
   CopyCFStruct			=> "CFStructName",
   CreateCFStruct		=> "CFStructName",
   DeleteCFStruct		=> "CFStructName",
   InquireCFStruct		=> "CFStructName",

  );

1;
