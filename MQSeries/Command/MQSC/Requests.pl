#
# $Id: Requests.pl,v 9.2 1999/11/02 23:45:25 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%Requests =
  (


   #
   # QueueManager commands
   #
   ChangeQueueManager		=> [ "ALTER QMGR",     	$RequestParameters{QueueManager} ],
   InquireQueueManager		=> [ "DISPLAY QMGR",   	$RequestParameters{QueueManager},
				     $RequestArgs{QueueManager}, ],
   PingQueueManager		=> [ "PING QMGR",		{} ],


   #
   # Process commands
   #
   ChangeProcess		=> [ "ALTER",     	$RequestParameters{Process} ],
   CopyProcess			=> [ "DEFINE",     	$RequestParameters{Process} ],
   CreateProcess		=> [ "DEFINE", 	     	$RequestParameters{Process} ],
   DeleteProcess		=> [ "DELETE",     	$RequestParameters{Process} ],
   InquireProcess		=> [ "DISPLAY",      	$RequestParameters{Process},
				     $RequestArgs{Process}, ],
   InquireProcessNames		=> [ "DISPLAY",      	$RequestParameters{Process} ],


   #
   # Queue commands
   #
   ChangeQueue			=> [ "ALTER",      	$RequestParameters{ChangeQueue} ],
   ClearQueue			=> [ "CLEAR",      	$RequestParameters{ClearQueue} ],
   CopyQueue			=> [ "DEFINE",     	$RequestParameters{CopyQueue} ],
   CreateQueue			=> [ "DEFINE",      	$RequestParameters{CreateQueue} ],
   DeleteQueue			=> [ "DELETE",      	$RequestParameters{DeleteQueue} ],
   InquireQueue			=> [ "DISPLAY",      	$RequestParameters{Queue},
				     $RequestArgs{Queue}, ],
   InquireQueueNames		=> [ "DISPLAY",      	$RequestParameters{InquireQueueNames} ],

   #
   # Not available in MQSC, it appears
   #
   ResetQueueStatistics		=> "",


   #
   # Channel commands
   #
   ChangeChannel		=> [ "ALTER",      	$RequestParameters{Channel} ],
   CopyChannel			=> [ "DEFINE",    	$RequestParameters{Channel} ],
   CreateChannel		=> [ "DEFINE",     	$RequestParameters{Channel} ],
   DeleteChannel		=> [ "DELETE",     	$RequestParameters{Channel} ],
   #
   # We have to override the key word used for ChannelType.  For most
   # of the channel commands, its CHLTYPE, but for DISPLAY, it is
   # TYPE.  Inconsistent, and annoying, but that is part of why PCF
   # exists in the first place...
   #
   InquireChannel		=> [
				    "DISPLAY", 
				    {
				     %{$RequestParameters{Channel}},
				     ChannelType =>
				     [
				      "TYPE",
				      $RequestValues{ChannelType}
				     ],
				    },
				    $RequestArgs{Channel},
				   ],
   #
   # Similarly, ChannelName maps to CHSTATUS, not CHANNEL, for this
   # command.
   #
   InquireChannelStatus		=> [
				    "DISPLAY",
				    {
				     %{$RequestParameters{Channel}},
				     ChannelName => [ "CHSTATUS", "string" ],
				    },
				    $RequestArgs{ChannelStatus},
				   ],

   InquireChannelNames		=> [ "DISPLAY",      	$RequestParameters{InquireChannelNames} ],
   PingChannel			=> [ "PING",      	$RequestParameters{Channel} ],
   ResetChannel			=> [ "RESET",     	$RequestParameters{Channel} ],
   ResolveChannel		=> [ "RESOLVE",     	$RequestParameters{Channel} ],
   StartChannel			=> [ "START",     	$RequestParameters{Channel} ],
   StartChannelInitiator	=> [ "START CHINIT",	$RequestParameters{Channel} ],
   StartChannelListener		=> [ "START LISTENER",	$RequestParameters{Channel} ],
   StopChannel			=> [ "STOP",      	$RequestParameters{Channel} ],

   #
   # New commands we need to add support for
   #
   ChangeNamelist		=> [ "ALTER",		$RequestParameters{Namelist} ],
   CreateNamelist		=> [ "DEFINE",		$RequestParameters{Namelist} ],
   DeleteNamelist		=> [ "DELETE",		$RequestParameters{Namelist} ],
   InquireNamelist		=> [ "DISPLAY",		$RequestParameters{Namelist} ],
   InquireNamelistNames		=> [ "DISPLAY",		$RequestParameters{Namelist} ],

   InquireClusterQueueManager	=> [ "DISPLAY",		$RequestParameters{Cluster} ],
   ResumeQueueManagerCluster	=> [ "RESUME QMGR",	$RequestParameters{Cluster} ],
   SuspendQueueManagerCluster	=> [ "SUSPEND QMGR",	$RequestParameters{Cluster} ],
   RefreshCluster		=> [ "REFRESH",		$RequestParameters{Cluster} ],
   ResetCluster			=> [ "RESET",		$RequestParameters{Cluster} ],

   ChangeSecurity		=> [
				    "CHANGE SECURITY",	
				    $RequestParameters{Security},
				   ],
   InquireSecurity		=> [ 
				    "DISPLAY SECURITY",
				    $RequestParameters{Security},
				   ],
   RefreshSecurity		=> [ 
				    "REFRESH SECURITY",
				    $RequestParameters{Security},
				   ],
   ReverifySecurity		=> [
				    "RVERIFY SECURITY",
				    $RequestParameters{Security},
				   ],
   
   ChangeStorageClass		=> [ "ALTER",		$RequestParameters{StorageClass} ],
   CreateStorageClass		=> [ "DEFINE",		$RequestParameters{StorageClass} ],
   DeleteStorageClass		=> [ "DELETE",		$RequestParameters{StorageClass} ],
   InquireStorageClass		=> [ "DISPLAY",		$RequestParameters{StorageClass} ],

   ChangeTrace			=> [ "ALTER",		$RequestParameters{Trace} ],
   InquireTrace			=> [ "DISPLAY",		$RequestParameters{Trace} ],
   StartTrace			=> [ "START",		$RequestParameters{Trace} ],
   StopTrace			=> [ "STOP",		$RequestParameters{Trace} ],

   ArchiveLog			=> [ "ARCHIVE LOG",	$RequestParameters{ArchiveLog} ],

   CreateBufferPool		=> [ "DEFINE",		$RequestParameters{BufferPool} ],

   CreatePageSetId		=> [ "DEFINE",		$RequestParameters{PageSetId} ],

   RecoverBootStrapDataSet	=> [ "RECOVER BSDS",	{} ],

   ResetTpipe			=> [ "RESET",		$RequestParameters{Tpipe} ],

   # XXX everything above this line has been sanity checked for 2.1/5.1
   
   InquireThread		=> [ "DISPLAY",		$RequestParameters{InquireThread} ],
   ResolveInDoubt		=> [ "RESOLVE",		$RequestParameters{ResolveInDoubt}],

  );

1;
