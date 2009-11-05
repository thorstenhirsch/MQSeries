#
# $Id: RequestArgs.pl,v 33.1 2009/07/10 17:04:42 biersma Exp $
#
# (c) 1999-2009 Morgan Stanley & Co. Incorporated
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%RequestArgs =
  (

   Queue =>
   {
    StorageClass		=> 1,
    QType			=> 1,
    QName			=> 1,
   },

   Channel =>
   {
    ChannelName			=> 1,
    ChannelType			=> 1,
   },

   ChannelStatus =>
   {
    ChannelName			=> 1,
    ChannelInstanceType		=> 1,
    ConnectionName		=> 1,
    XmitQName			=> 1,
   },

   Process =>
   {
    ProcessName			=> 1,
   },

   QueueManager => {},

   Namelist =>
   {
    NamelistName		=> 1,
   },

   ResetQueueStatistics =>
   {
    QName                       => 1,
   },

  );

1;
