#
# $Id: ResponseParameters.pl,v 13.2 2000/03/24 20:34:42 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%ResponseParameters =
  (
   QueueManager =>
   {
    AUTHOREV	=> [ "AuthorityEvent", 		$ResponseValues{Enabled} ],
    CCSID	=> [ "CodedCharSetId" ],
    CHAD	=> [ "ChannelAutoDef",		$ResponseValues{Enabled} ],
    CHADEV	=> [ "ChannelAutoDefEvent",	$ResponseValues{Enabled} ],
    CHADEXIT	=> [ "ChannelAutoDefExit" ],
    CMDLEVEL	=> [ "CommandLevel" ],
    COMMANDQ	=> [ "CommandInputQName" ],
    CPILEVEL	=> [ "" ],
    DEADQ	=> [ "DeadLetterQName" ],
    DEFXMITQ	=> [ "DefXmitQName" ],
    DESCR	=> [ "QMgrDesc" ],
    DISTL	=> [ "DistLists",		$ResponseValues{Yes} ],
    INHIBTEV	=> [ "InhibitEvent",		$ResponseValues{Enabled} ],
    LOCALEV	=> [ "LocalEvent",		$ResponseValues{Enabled} ],
    MAXHANDS	=> [ "MaxHandles" ],
    MAXMSGL	=> [ "MaxMsgLength" ],
    MAXPRTY	=> [ "MaxPriority" ],
    MAXUMSGS	=> [ "MaxUncommittedMsgs" ],
    PERFMEV	=> [ "PerformanceEvent",	$ResponseValues{Enabled} ],
    PLATFORM	=> [ "Platform", ],
    QMNAME	=> [ "QMgrName" ],
    REMOTEEV	=> [ "RemoteEvent",		$ResponseValues{Enabled} ],
    STRSTPEV	=> [ "StartStopEvent",		$ResponseValues{Enabled} ],
    SYNCPT	=> [ "SyncPoint",		$ResponseValues{Available} ],
    TRIGINT	=> [ "TriggerInterval" ],

    ALTTIME	=> [ "AlterationTime" ],
    ALTDATE	=> [ "AlterationDate" ],
    CLWLEXIT	=> [ "ClusterWorkLoadExit" ],
    CLWLDATA	=> [ "ClusterWorkLoadData" ],
    CLWLLEN 	=> [ "ClusterWorkLoadLength" ],
    QMID	=> [ "QMgrIdentifier" ],
    REPOS	=> [ "RepositoryName" ],
    REPOSNL	=> [ "RepositoryNamelist" ],
   },

   Process =>
   {
    APPLTYPE	=> [ "ApplType",		$ResponseValues{ApplType} ],

    PROCESS	=> [ "ProcessName" ],
    DESCR	=> [ "ProcessDesc" ],
    APPLICID	=> [ "ApplId" ],
    ENVRDATA	=> [ "EnvData" ],
    USERDATA	=> [ "UserData" ],

    ALTTIME	=> [ "AlterationTime" ],
    ALTDATE	=> [ "AlterationDate" ],
   },

   Queue =>
   {
    BOQNAME	=> [ "BackoutRequeueName" ],
    BOTHRESH	=> [ "BackoutThreshold" ],
    CRDATE	=> [ "CreationDate" ],
    CRTIME	=> [ "CreationTime" ],
    CURDEPTH	=> [ "CurrentQDepth" ],
    DEFPRTY	=> [ "DefPriority" ],
    DEFPSIST	=> [ "DefPersistence",		$ResponseValues{Yes} ],
    DEFSOPT	=> [ "DefInputOpenOption",	$ResponseValues{DefInputOpenOption} ],
    DEFTYPE	=> [ "DefinitionType",		$ResponseValues{DefinitionType} ],
    DESCR	=> [ "QDesc" ],
    DISTL	=> [ "DistLists",		$ResponseValues{Yes} ],
    GET		=> [ "InhibitGet",		$ResponseValues{Enabled} ],
    INDXTYPE	=> [ "IndexType",		$ResponseValues{IndexType} ],
    INITQ	=> [ "InitiationQName" ],
    IPPROCS	=> [ "OpenInputCount" ],
    MAXDEPTH	=> [ "MaxQDepth" ],
    MAXMSGL	=> [ "MaxMsgLength" ],
    MSGDLVSQ	=> [ "MsgDeliverySequence",	$ResponseValues{MsgDeliverySequence} ],
    OPPROCS	=> [ "OpenOutputCount" ],
    PROCESS	=> [ "ProcessName" ],
    PUT		=> [ "InhibitPut",		$ResponseValues{Enabled} ],
    QDEPTHHI	=> [ "QDepthHighLimit" ],
    QDEPTHLO	=> [ "QDepthLowLimit" ],
    QDPHIEV	=> [ "QDepthHighEvent",		$ResponseValues{Enabled} ],
    QDPLOEV	=> [ "QDepthLowEvent",		$ResponseValues{Enabled} ],
    QDPMAXEV	=> [ "QDepthMaxEvent",		$ResponseValues{Enabled} ],
    QSVCINT	=> [ "QServiceInterval" ],
    QSVCIEV	=> [ "QServiceIntervalEvent",   $ResponseValues{QServiceIntervalEvent} ],
    TYPE	=> [ "QType",  			$ResponseValues{QType} ],
    QUEUE	=> [ "QName" ],
    RETINTVL	=> [ "RetentionInterval" ],
    RNAME	=> [ "RemoteQName" ],
    RQMNAME	=> [ "RemoteQMgrName" ],
    SCOPE	=> [ "Scope",			$ResponseValues{Scope} ],
    STGCLASS	=> [ "StorageClass" ],
    TARGQ	=> [ "BaseQName" ],
    TRIGDATA	=> [ "TriggerData" ],
    TRIGDPTH	=> [ "TriggerDepth" ],
    TRIGMPRI	=> [ "TriggerMsgPriority" ],
    TRIGTYPE	=> [ "TriggerType",		$ResponseValues{TriggerType} ],
    USAGE	=> [ "Usage",			$ResponseValues{Usage} ],
    XMITQ	=> [ "XmitQName" ],

    TRIGGER	=> [ "TriggerControl",		1 ],
    NOTRIGGER	=> [ "TriggerControl",		0 ],
    SHARE	=> [ "Shareability",		1 ],
    NOSHARE	=> [ "Shareability",		0 ],
    HARDENBO	=> [ "HardenGetBackout",	1 ],
    NOHARDENBO	=> [ "HardenGetBackout",	0 ],

    ALTTIME	=> [ "AlterationTime" ],
    ALTDATE	=> [ "AlterationDate" ],
    CLUSDATE	=> [ "ClusterDate" ],
    CLUSNL   	=> [ "ClusterNamelist" ],
    CLUSQMGR 	=> [ "QMgrName" ],
    CLUSQT  	=> [ "ClusterQType",		$ResponseValues{ClusterQType} ],
    CLUSTER   	=> [ "ClusterName" ],
    CLUSTIME  	=> [ "ClusterTime" ],
    DEFBIND	=> [ "DefBind",			$ResponseValues{DefBind} ],
    QMID   	=> [ "QMgrIdentifier" ],

   },

   Channel =>
   {
    #
    # Most of these are primarily from DISPLAY CHSTATUS 
    #
    BATCHES	=> [ "Batches" ],
    BUFSRCVD	=> [ "BuffersReceived" ],
    BUFSSENT	=> [ "BuffersSent" ],
    BYTSRCVD	=> [ "BytesReceived" ],
    BYTSSENT	=> [ "BytesSent" ],
    CHSTADA	=> [ "ChannelStartDate" ],
    CHSTATI	=> [ "ChannelStartTime" ],
    CHSTATUS	=> [ "ChannelName" ],
    CURLUWID	=> [ "CurrentLUWID" ],
    CURMSGS	=> [ "CurrentMsgs" ],
    CURSEQNO	=> [ "CurrentSequenceNumber" ],
    INDOUBT	=> [ "InDoubtStatus",		$ResponseValues{Yes} ],
    JOBNAME	=> [ "MCAJobName" ],
    LONGRTS	=> [ "LongRetriesLeft" ],
    LSTLUWID	=> [ "LastLUWID" ],
    LSTMSGDA	=> [ "LastMsgDate" ],
    LSTMSGTI	=> [ "LastMsgTime" ],
    LSTSEQNO	=> [ "LastSequenceNumber" ],
    MCASTAT	=> [ "MCAStatus",		$ResponseValues{MCAStatus} ],
    MSGS	=> [ "Msgs" ],
    SHORTRTS	=> [ "ShortRetriesLeft" ],
    STATUS	=> [ "ChannelStatus",		$ResponseValues{ChannelStatus} ],
    STOPREQ	=> [ "StopRequested",		$ResponseValues{Yes} ],

    CURRENT	=> [ "ChannelInstanceType",	"Current" ],
    SAVED	=> [ "ChannelInstanceType",	"Saved" ],

    #
    # Most of these are from DISPLAY CHANNEL, but also returned by
    # CHSTATUS, too.  Thus, one hash.
    #
    BATCHINT	=> [ "BatchInterval" ],
    BATCHSZ	=> [ "BatchSize" ],
    CHANNEL	=> [ "ChannelName" ],
    CHLTYPE	=> [ "ChannelType",		$ResponseValues{ChannelType} ],
    CONNAME	=> [ "ConnectionName" ],
    CONVERT	=> [ "DataConversion",		$ResponseValues{Yes} ],
    DESCR	=> [ "ChannelDesc" ],
    DISCINT	=> [ "DiscInterval" ],
    HBINT	=> [ "HeartbeatInterval" ],
    LONGRTY	=> [ "LongRetryCount" ],
    LONGTMR	=> [ "LongRetryInterval" ],
    MAXMSGL	=> [ "MaxMsgLength" ],
    MCANAME	=> [ "MCAName" ],
    MCATYPE	=> [ "MCAType",			$ResponseValues{MCAType} ],
    MCAUSER	=> [ "MCAUserIdentifier" ],
    MODENAME	=> [ "ModeName" ],
    MREXIT	=> [ "MsgRetryExit" ],
    MRDATA	=> [ "MsgRetryUserData" ],
    MRRTY	=> [ "MsgRetryCount" ],
    MRTMT	=> [ "MsgRetryInterval" ],
    MSGDATA	=> [ "MsgUserData" ],
    MSGEXIT	=> [ "MsgExit" ],
    NPMSPEED	=> [ "NonPersistentMsgSpeed",   $ResponseValues{NonPersistentMsgSpeed} ],
    PASSWORD	=> [ "Password" ],
    PUTAUT	=> [ "PutAuthority",		$ResponseValues{PutAuthority} ],
    QMNAME	=> [ "QMgrName" ],
    RCVDATA	=> [ "ReceiveUserData" ],
    RCVEXIT	=> [ "ReceiveExit" ],
    SCYEXIT	=> [ "SecurityExit" ],
    SCYDATA	=> [ "SecurityUserData" ],
    SENDDATA	=> [ "SendUserData" ],
    SENDEXIT	=> [ "SendExit" ],
    SEQWRAP	=> [ "SeqNumberWrap" ],
    SHORTRTY	=> [ "ShortRetryCount" ],
    SHORTTMR	=> [ "ShortRetryInterval" ],
    TPNAME	=> [ "TpName" ],
    TRPTYPE	=> [ "TransportType",		$ResponseValues{TransportType} ],
    USERID	=> [ "UserIdentifier" ],
    XMITQ	=> [ "XmitQName" ],

    ALTTIME	=> [ "AlterationTime" ],
    ALTDATE	=> [ "AlterationDate" ],
    AUTOSTART	=> [ "AutoStart",		$ResponseValues{Enabled} ],
    CLUSTER	=> [ "ClusterName" ],
    CLUSNL   	=> [ "ClusterNamelist" ],
    NETPRTY 	=> [ "NetworkPriority" ],

   },

   Namelist =>
   {
    ALTTIME	=> [ "AlterationTime" ],
    ALTDATE	=> [ "AlterationDate" ],
    DESCR	=> [ "NamelistDesc" ],
    NAMELIST	=> [ "NamelistName" ],
    NAMCOUNT  	=> [ "NamelistCount" ],
    NAMES   	=> [ "Names" ],
   },

   StorageClass =>
   {
    STGCLASS	=> [ "StorageClassName" ],
    PSID	=> [ "PageSetId" ],
    ALTTIME	=> [ "AlterationTime" ],
    ALTDATE	=> [ "AlterationDate" ],
    DESCR	=> [ "StorageClassDesc" ],
    XCFGNAME	=> [ "XCFGroupName" ],
    XCFMNAME	=> [ "XCFMemberName" ],
   },

   Trace =>
   {
    TRACE	=> [ "TraceType",		$ResponseValues{TraceType} ],
    DEST	=> [ "Destination" ],
    CLASS	=> [ "Class" ],
    RMID	=> [ "ResourceMgrId" ],
    TNO		=> [ "TraceNumber" ],
    USERID	=> [ "UserIdentifier" ],
    COMMENT	=> [ "Comment" ],
    IFCID	=> [ "EventId" ],
   },

   Cluster =>
   {
    ALTDATE	=> [ "AlterationDate" ],
    ALTTIME	=> [ "AlterationTime" ],
    BATCHINT	=> [ "BatchInterval" ],
    BATCHSZ	=> [ "BatchSize" ],
    CHANNEL	=> [ "ChannelName" ],
    CLUSDATE	=> [ "ClusterDate" ],
    CLUSTER 	=> [ "ClusterName" ],
    CLUSTIME	=> [ "ClusterTime" ],
    CONNAME	=> [ "ConnectionName" ],
    CONVERT	=> [ "DataConversion",		$ResponseValues{Yes} ],
    DEFTYPE	=> [ "QMgrDefinitionType",	$ResponseValues{QMgrDefinitionType} ],
    DESCR	=> [ "ChannelDesc" ],
    DISCINT	=> [ "DiscInterval" ],
    HBINT	=> [ "HeartbeatInterval" ],
    LONGRTY	=> [ "LongRetryCount" ],
    LONGTMR	=> [ "LongRetryInterval" ],
    MAXMSGL	=> [ "MaxMsgLength" ],
    MCANAME	=> [ "MCAName" ],
    MCATYPE	=> [ "MCAType",			$ResponseValues{MCAType} ],
    MCAUSER	=> [ "MCAUserIdentifier" ],
    MODENAME	=> [ "ModeName" ],
    MRDATA	=> [ "MsgRetryUserData" ],
    MREXIT	=> [ "MsgRetryExit" ],
    MRRTY	=> [ "MsgRetryCount" ],
    MRTMR	=> [ "MsgRetryInterval" ],
    MSGDATA	=> [ "MsgUserData" ],
    MSGEXIT	=> [ "MsgExit" ],
    NETPRTY 	=> [ "NetworkPriority" ],
    NPMSPEED    => [ "NonPersistentMsgSpeed",	$ResponseValues{NonPersistentMsgSpeed} ],
    PASSWORD	=> [ "Password" ],
    PUTAUT	=> [ "PutAuthority",		$ResponseValues{PutAuthority} ],
    QMID	=> [ "QMgrIdentifier" ],
    QMTYPE	=> [ "QMgrType",		$ResponseValues{QMgrType} ],
    RCVDATA	=> [ "ReceiveUserData" ],
    RCVEXIT	=> [ "ReceiveExit" ],
    SCYDATA	=> [ "SecurityUserData" ],
    SCYEXIT	=> [ "SecurityExit" ],
    SENDDATA	=> [ "SendUserData" ],
    SENDEXIT	=> [ "SendExit" ],
    SEQWRAP	=> [ "SeqNumberWrap" ],
    SHORTRTY	=> [ "ShortRetryCount" ],
    SHORTTMR	=> [ "ShortRetryInterval" ],
    STATUS	=> [ "ChannelStatus",		$ResponseValues{ChannelStatus} ],
    SUSPEND	=> [ "Suspend",			$ResponseValues{Yes} ],
    TPNAME	=> [ "TpName" ],
    TRPTYPE	=> [ "TransportType",		$ResponseValues{TransportType} ],
    USERID	=> [ "UserIdentifier" ],
   },

  );

1;
