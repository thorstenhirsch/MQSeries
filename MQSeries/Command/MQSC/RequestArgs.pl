#
# $Id: RequestArgs.pl,v 23.1 2003/04/10 19:09:40 biersma Exp $
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
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
