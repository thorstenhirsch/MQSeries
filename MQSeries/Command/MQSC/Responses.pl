#
# $Id: Responses.pl,v 20.1 2002/03/18 20:33:55 biersma Exp $
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%Responses =
  (
   ChangeQueueManager 		=> $ResponseParameters{QueueManager}, 
   InquireQueueManager 		=> $ResponseParameters{QueueManager}, 
   PingQueueManager 		=> $ResponseParameters{QueueManager}, 

   ChangeProcess 		=> $ResponseParameters{Process}, 
   CopyProcess 			=> $ResponseParameters{Process}, 
   CreateProcess 		=> $ResponseParameters{Process}, 
   DeleteProcess 		=> $ResponseParameters{Process}, 
   InquireProcess 		=> $ResponseParameters{Process}, 
   InquireProcessNames 		=> $ResponseParameters{Process}, 

   ChangeQueue 			=> $ResponseParameters{Queue}, 
   ClearQueue 			=> $ResponseParameters{Queue}, 
   CopyQueue 			=> $ResponseParameters{Queue}, 
   CreateQueue 			=> $ResponseParameters{Queue}, 
   DeleteQueue 			=> $ResponseParameters{Queue}, 
   InquireQueue 		=> $ResponseParameters{Queue}, 
   InquireQueueNames 		=> $ResponseParameters{Queue}, 
   ResetQueueStatistics 	=> $ResponseParameters{Queue}, 

   ChangeChannel 		=> $ResponseParameters{Channel}, 
   CopyChannel 			=> $ResponseParameters{Channel}, 
   CreateChannel 		=> $ResponseParameters{Channel}, 
   DeleteChannel 		=> $ResponseParameters{Channel}, 
   InquireChannel 		=> $ResponseParameters{Channel}, 
   InquireChannelNames 		=> $ResponseParameters{Channel}, 
   InquireChannelStatus 	=> $ResponseParameters{Channel}, 
   PingChannel 			=> $ResponseParameters{Channel}, 
   ResetChannel 		=> $ResponseParameters{Channel}, 
   ResolveChannel 		=> $ResponseParameters{Channel}, 
   StartChannel 		=> $ResponseParameters{Channel}, 
   StartChannelInitiator 	=> $ResponseParameters{Channel}, 
   StartChannelListener 	=> $ResponseParameters{Channel}, 
   StopChannel 			=> $ResponseParameters{Channel}, 

   ChangeNamelist		=> $ResponseParameters{Namelist},
   CreateNamelist		=> $ResponseParameters{Namelist},
   DeleteNamelist		=> $ResponseParameters{Namelist},
   InquireNamelist		=> $ResponseParameters{Namelist},
   InquireNamelistNames		=> $ResponseParameters{Namelist},

   InquireStorageClass		=> $ResponseParameters{StorageClass},
   InquireStorageClassNames	=> $ResponseParameters{StorageClass},

   InquireTrace			=> $ResponseParameters{Trace},

   InquireClusterQueueManager	=> $ResponseParameters{Cluster},
  );

#
# This is used to determine how to map multiple MQSC responses into
# one MQSeries::Command response.  All the 'old_key' fields of the
# individual MQSC responses are collected into one 'new_key' field of
# the MQSeries::Command response.
#
# Format: CommandName => [ old_key, new_key ]
#
%ResponseList =
  (
   InquireProcessNames		=> [ qw(ProcessName ProcessNames) ],
   InquireQueueNames		=> [ qw(QName QNames) ],
   InquireChannelNames		=> [ qw(ChannelName ChannelNames) ],
   InquireNamelistNames		=> [ qw(NamelistName NamelistNames) ],
   InquireStorageClassNames	=> [ qw(StorageClassName StorageClassNames) ],
  );

1;
