#
# $Id: ResponseParameters.pl,v 23.2 2003/04/15 13:34:28 biersma Exp $
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%ResponseParameters =
  (
   QueueManager =>
   {
    ALTTIME	=> [ "AlterationTime" ],
    ALTDATE	=> [ "AlterationDate" ],
    AUTHOREV	=> [ "AuthorityEvent", 		$ResponseValues{Enabled} ],
    CCSID	=> [ "CodedCharSetId" ],
    CHAD	=> [ "ChannelAutoDef",		$ResponseValues{Enabled} ],
    CHADEV	=> [ "ChannelAutoDefEvent",	$ResponseValues{Enabled} ],
    CHADEXIT	=> [ "ChannelAutoDefExit" ],
    CLWLEXIT	=> [ "ClusterWorkLoadExit" ],
    CLWLDATA	=> [ "ClusterWorkLoadData" ],
    CLWLLEN 	=> [ "ClusterWorkLoadLength" ],
    CMDLEVEL	=> [ "CommandLevel" ],
    COMMANDQ	=> [ "CommandInputQName" ],
    CONFIGEV    => [ "ConfigurationEvent",      $ResponseValues{Enabled} ],
    CPILEVEL	=> [ "" ],
    DEADQ	=> [ "DeadLetterQName" ],
    DEFXMITQ	=> [ "DefXmitQName" ],
    DESCR	=> [ "QMgrDesc" ],
    DISTL	=> [ "DistLists",		$ResponseValues{Yes} ],
    EXPRYINT    => [ "ExpiryInterval" ],
    IGQ         => [ "IntraGroupQueueing",      $ResponseValues{Enabled} ],
    IGQAUT      => [ "IntraGroupAuthority",     $ResponseValues{IntraGroupAuthority} ],
    IGQUSER     => [ "IntraGroupUser" ],
    INHIBTEV	=> [ "InhibitEvent",		$ResponseValues{Enabled} ],
    LOCALEV	=> [ "LocalEvent",		$ResponseValues{Enabled} ],
    MAXHANDS	=> [ "MaxHandles" ],
    MAXMSGL	=> [ "MaxMsgLength" ],
    MAXPRTY	=> [ "MaxPriority" ],
    MAXUMSGS	=> [ "MaxUncommittedMsgs" ],
    PERFMEV	=> [ "PerformanceEvent",	$ResponseValues{Enabled} ],
    PLATFORM	=> [ "Platform", ],
    QMID	=> [ "QMgrIdentifier" ],
    QMNAME	=> [ "QMgrName" ],
    QSGNAME     => [ "QSharingGroupName" ],
    REMOTEEV	=> [ "RemoteEvent",		$ResponseValues{Enabled} ],
    REPOS	=> [ "RepositoryName" ],
    REPOSNL	=> [ "RepositoryNamelist" ],
    SSLCRLNL    => [ "SSLCRLNamelist" ],
    SSLKEYR     => [ "SSLKeyRepository" ],
    SSLTASKS    => [ "SSLTasks" ],
    STRSTPEV	=> [ "StartStopEvent",		$ResponseValues{Enabled} ],
    SYNCPT	=> [ "SyncPoint",		$ResponseValues{Available} ],
    TRIGINT	=> [ "TriggerInterval" ],
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

    QSGDISP     => [ "QSharingGroupDisposition", $ResponseValues{QSharingGroupDisposition} ],
   },

   Queue =>
   {
    BOQNAME	=> [ "BackoutRequeueName" ],
    BOTHRESH	=> [ "BackoutThreshold" ],
    CFSTRUCT    => [ "CouplingStructure" ],
    CHLDISP     => [ "ChannelDisposition" ],
    CMDSCOPE    => [ "CommandScope" ],
    CRDATE	=> [ "CreationDate" ],
    CRTIME	=> [ "CreationTime" ],
    CURDEPTH	=> [ "CurrentQDepth" ],
    DEFPRTY	=> [ "DefPriority" ],
    DEFPSIST	=> [ "DefPersistence",		$ResponseValues{Yes} ],
    DEFSOPT	=> [ "DefInputOpenOption",	$ResponseValues{DefInputOpenOption} ],
    DEFTYPE	=> [ "DefinitionType",		$ResponseValues{DefinitionType} ],
    DESCR	=> [ "QDesc" ],
    DISTL	=> [ "DistLists",		$ResponseValues{Yes} ],
    GET		=> [ "InhibitGet",		$ResponseValues{Disabled} ],
    IGQ         => [ "IntraGroupQueueing" ],
    IGQAUT      => [ "IntraGroupAuthority" ],
    IGQUSER     => [ "IntraGroupUser" ],
    INDXTYPE	=> [ "IndexType",		$ResponseValues{IndexType} ],
    INITQ	=> [ "InitiationQName" ],
    IPPROCS	=> [ "OpenInputCount" ],
    MAXDEPTH	=> [ "MaxQDepth" ],
    MAXMSGL	=> [ "MaxMsgLength" ],
    MSGDLVSQ	=> [ "MsgDeliverySequence",	$ResponseValues{MsgDeliverySequence} ],
    OPPROCS	=> [ "OpenOutputCount" ],
    PROCESS	=> [ "ProcessName" ],
    PSID        => [ "PageSetId" ],
    PUT		=> [ "InhibitPut",		$ResponseValues{Disabled} ],
    QDEPTHHI	=> [ "QDepthHighLimit" ],
    QDEPTHLO	=> [ "QDepthLowLimit" ],
    QDPHIEV	=> [ "QDepthHighEvent",		$ResponseValues{Enabled} ],
    QDPLOEV	=> [ "QDepthLowEvent",		$ResponseValues{Enabled} ],
    QDPMAXEV	=> [ "QDepthMaxEvent",		$ResponseValues{Enabled} ],
    QSVCINT	=> [ "QServiceInterval" ],
    QSVCIEV	=> [ "QServiceIntervalEvent",   $ResponseValues{QServiceIntervalEvent} ],
    TYPE	=> [ "QType",  			$ResponseValues{QType} ],
    QUEUE	=> [ "QName" ],
    QSGDISP     => [ "QSharingGroupDisposition", $ResponseValues{QSharingGroupDisposition} ],
    QSGNAME     => [ "QSharingGroupName" ],
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

    # 
    # ResetQueueStatistics (For MVS version of MQ release 5.2 and up)
    #
    HIQDEPTH    => [ "HighQDepth" ],
    MSGSIN      => [ "MsgEnqCount" ],
    MSGSOUT     => [ "MsgDeqCount" ],
    RESETINT    => [ "TimeSinceReset" ],
    QSTATS      => [ "QName" ],
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
    BATCHHB     => [ "BatchHeartBeat" ],
    BATCHINT	=> [ "BatchInterval" ],
    BATCHSZ	=> [ "BatchSize" ],
    CHANNEL	=> [ "ChannelName" ],
    CHLTYPE	=> [ "ChannelType",		$ResponseValues{ChannelType} ],
    CONNAME	=> [ "ConnectionName" ],
    CONVERT	=> [ "DataConversion",		$ResponseValues{Yes} ],
    DESCR	=> [ "ChannelDesc" ],
    DISCINT	=> [ "DiscInterval" ],
    HBINT	=> [ "HeartbeatInterval" ],
    KAINT       => [ "KeepAliveInterval" ],
    LOCLADDR    => [ "LocalAddress" ],
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
    RQMNAME	=> [ "RemoteQMgrName" ],
    SCYEXIT	=> [ "SecurityExit" ],
    SCYDATA	=> [ "SecurityUserData" ],
    SENDDATA	=> [ "SendUserData" ],
    SENDEXIT	=> [ "SendExit" ],
    SEQWRAP	=> [ "SeqNumberWrap" ],
    SHORTRTY	=> [ "ShortRetryCount" ],
    SHORTTMR	=> [ "ShortRetryInterval" ],
    SSLCAUTH => => [ "SSLClientAuth",           $ResponseValues{SSLClientAuth} ],
    SSLCIPH     => [ "SSLCipherSpec" ],
    SSLPEER     => [ "SSLPeerName" ],
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

    CHLDISP     => [ "ChannelDisposition",      $ResponseValues{ChannelDisposition} ],
    QSGDISP     => [ "QSharingGroupDisposition", $ResponseValues{QSharingGroupDisposition} ],
   },

   Namelist =>
   {
    ALTTIME	=> [ "AlterationTime" ],
    ALTDATE	=> [ "AlterationDate" ],
    DESCR	=> [ "NamelistDesc" ],
    NAMELIST	=> [ "NamelistName" ],
    NAMCOUNT  	=> [ "NameCount" ],
    NAMES   	=> [ "Names" ],
    NLTYPE      => [ "NamelistType",            $ResponseValues{NamelistType} ],
    QSGDISP     => [ "QSharingGroupDisposition", $ResponseValues{QSharingGroupDisposition} ],
   },

   StorageClass =>
   {
    STGCLASS	=> [ "StorageClassName" ],
    ALTTIME	=> [ "AlterationTime" ],
    ALTDATE	=> [ "AlterationDate" ],
    DESCR	=> [ "StorageClassDesc" ],
    PSID	=> [ "PageSetId" ],
    QSGDISP     => [ "QSharingGroupDisposition", $ResponseValues{QSharingGroupDisposition} ],
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

   QueueStatus => 
   {
    APPLTAG     => [ "ApplTag" ],
    APPLTYPE    => [ "ApplType",                $ResponseValues{ApplType} ],
    ASID        => [ "AddressSpaceId" ],
    BROWSE      => [ "Browse",                  $ResponseValues{Yes} ],
    CHANNEL     => [ "ChannelName" ],
    CONNAME     => [ "Conname" ],
    CURDEPTH    => [ "CurrentQDepth" ],
    INPUT       => [ "Input",                   $ResponseValues{QStatusInputType} ],
    INQUIRE     => [ "Inquire",                 $ResponseValues{Yes} ],
    IPPROCS     => [ "OpenInputCount" ],
    OPPROCS     => [ "OpenOutputCount" ],
    OUTPUT      => [ "Output",                  $ResponseValues{Yes} ],
    PSBNAME     => [ "PSBName" ],
    PSTID       => [ "PSTId" ],
    QSGDISP     => [ "QSharingGroupDisposition", $ResponseValues{QSharingGroupDisposition} ],
    QSTATUS     => [ "QName" ],
    SET         => [ "Set",                     $ResponseValues{Yes} ],
    TASKNO      => [ "TaskNumber" ],
    TRANSID     => [ "TransactionId" ],
    TYPE        => [ "StatusType",              $ResponseValues{StatusType} ],
    UNCOM       => [ "UncommittedMsgs" ],
    URID        => [ "URId" ],
    USERID      => [ "UserIdentifier" ],
   },

   AuthInfo =>
   {
    ALTDATE	=> [ "AlterationDate" ],
    ALTTIME	=> [ "AlterationTime" ],
    AUTHINFO    => [ "AuthInfoName" ],
    AUTHTYPE    => [ "AuthInfoType",            $ResponseValues{AuthInfoType} ],
    CONNAME     => [ "AuthInfoConnName" ],
    DESCR       => [ "AuthInfoDesc" ],
    LDAPPWD     => [ "LDAPPassword" ],
    LDAPUSER    => [ "LDAPUserName" ],
    QSGDISP     => [ "QSharingGroupDisposition", $ResponseValues{QSharingGroupDisposition} ],
   },

   CFStruct     => 
   {
    ALTDATE	=> [ "AlterationDate" ],
    ALTTIME	=> [ "AlterationTime" ],
    CFLEVEL     => [ "CFStructLevel" ],
    CFSTRUCT    => [ "CFStructName" ],
    DESCR       => [ "CFStructDesc" ],
    RECOVER     => [ "Recovery",                $ResponseValues{Yes} ],
   },

  );

1;
