#
# $Id: RequestParameters.pl,v 9.2 1999/11/02 23:45:09 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%RequestParameters =
  (

   QueueManager =>
   {
    Force			=> [ "FORCE" ],
    QMgrDesc			=> [ "DESCR", 		"string" ],
    TriggerInterval		=> [ "TRIGINT", 	"integer" ],
    DeadLetterQName		=> [ "DEADQ", 		"string" ],
    MaxHandles			=> [ "MAXHANDS", 	"integer" ],
    MaxUncommittedMsgs		=> [ "MAXUMSGS", 	"integer" ],
    DefXmitQName		=> [ "DEFXMITQ",	"string" ],
    AuthorityEvent		=> [ "AUTHOREV", 	$RequestValues{Enabled} ],
    InhibitEvent		=> [ "INHIBTEV",	$RequestValues{Enabled} ],
    LocalEvent			=> [ "LOCALEV",		$RequestValues{Enabled} ],
    RemoteEvent			=> [ "REMOTEEV",	$RequestValues{Enabled} ],
    StartStopEvent		=> [ "STRSTPEV",	$RequestValues{Enabled} ],
    PerformanceEvent		=> [ "PERFMEV",		$RequestValues{Enabled} ],
    MaxMsgLength		=> [ "MAXMSGL",		"integer" ],
    ChannelAutoDef		=> [ "CHAD",		$RequestValues{Enabled} ],
    ChannelAutoDefEvent		=> [ "CHADEV",		$RequestValues{Enabled} ],
    ChannelAutoDefExit 		=> [ "CHADEXIT",	"string" ],
    QMgrAttrs			=> [ "",		$RequestValues{QMgrAttrs} ],

    ClusterWorkLoadExit		=> [ "CLWLEXIT",	"string" ],
    ClusterWorkLoadData		=> [ "CLWLDATA",	"string" ],
    ClusterWorkLoadLength	=> [ "CLWLLEN",		"string" ],
    RepositoryName 		=> [ "REPOS",		"string" ],
    RepositoryNamelist		=> [ "REPOSNL",		"string" ],
    CodedCharSetId		=> [ "CCSID",		"integer" ],

   },

   Process =>
   {
    Replace			=> [ "",		$RequestValues{Replace} ],
    ApplId			=> [ "APPLICID",	"string" ],
    ApplType			=> [ "APPLTYPE",	$RequestValues{ApplType} ],
    EnvData			=> [ "ENVRDATA",	"string" ],
    UserData			=> [ "USERDATA",	"string" ],
    ProcessName			=> [ "PROCESS",		"string" ],
    ToProcessName		=> [ "PROCESS",		"string" ],
    FromProcessName		=> [ "LIKE",		"string" ],
    ProcessDesc			=> [ "DESCR",		"string" ],
    ProcessAttrs		=> [ "",		$RequestValues{ProcessAttrs} ],
   },

   InquireQueueNames =>
   {
    QName			=> [ "QUEUE",		"string" ],
    QType			=> [ "TYPE",		$RequestValues{QType} ],
   },

   Queue =>
   {
    BackoutRequeueName		=> [ "BOQNAME",		"string" ],
    BackoutThreshold		=> [ "BOTHRESH", 	"integer" ],
    BaseQName			=> [ "TARGQ", 		"string" ],
    DefInputOpenOption		=> [ "DEFSOPT",		$RequestValues{DefInputOpenOption} ],
    DefPersistence		=> [ "DEFPSIST",	$RequestValues{Yes} ],
    DefPriority			=> [ "DEFPRTY", 	"integer" ],
    DefinitionType		=> [ "DEFTYPE", 	$RequestValues{DefinitionType} ],
    DistLists			=> [ "DISTL",		$RequestValues{Yes} ],
    Force			=> [ "FORCE" ],
    FromQName			=> [ "LIKE",		"string" ],
    HardenGetBackout		=> [ "HARDENBO", 	$RequestValues{HardenGetBackout} ],
    InhibitGet			=> [ "GET", 		$RequestValues{Enabled} ],
    InhibitPut			=> [ "PUT",		$RequestValues{Enabled} ],
    InitiationQName		=> [ "INITQ",		"string" ],
    MaxMsgLength		=> [ "MAXMSGL", 	"integer" ],
    MaxQDepth			=> [ "MAXDEPTH",	"integer" ],
    MsgDeliverySequence		=> [ "MSGDLVSQ",	$RequestValues{MsgDeliverySequence} ],
    ProcessName			=> [ "PROCESS",		"string" ],
    QDepthHighEvent		=> [ "QDPHIEV",		$RequestValues{Enabled} ],
    QDepthHighLimit		=> [ "QDEPTHHI",	"integer" ],
    QDepthLowEvent		=> [ "QDPLOEV",		$RequestValues{Enabled} ],
    QDepthLowLimit		=> [ "QDEPTHLO", 	"integer" ],
    QDepthMaxEvent		=> [ "QDPMAXEV",	$RequestValues{Enabled} ],
    QDesc			=> [ "DESCR", 		"string" ],
    QName			=> [ "QUEUE",		"string" ],
    QServiceInterval		=> [ "QSVCINT",		"integer" ],
    QServiceIntervalEvent 	=> [ "QSVCIEV",		$RequestValues{QServiceIntervalEvent} ],
    QType			=> [ "TYPE",		$RequestValues{QType} ],
    RemoteQMgrName		=> [ "RQMNAME", 	"string" ],
    RemoteQName			=> [ "RNAME",		"string" ],
    Replace			=> [ "",		$RequestValues{Replace} ],
    RetentionInterval		=> [ "RETINTVL",	"integer" ],
    Scope 			=> [ "SCOPE", 		$RequestValues{Scope} ],
    Shareability		=> [ "",		$RequestValues{Shareability} ],
    ToQName			=> [ "QUEUE",		"string" ],
    TriggerControl		=> [ "",		$RequestValues{TriggerControl} ],
    TriggerData			=> [ "TRIGDATA",      	"string" ],
    TriggerDepth		=> [ "TRIGDPTH", 	"integer" ],
    TriggerMsgPriority		=> [ "TRIGMPRI",	"integer" ],
    TriggerType			=> [ "TRIGTYPE", 	$RequestValues{TriggerType} ],
    Usage			=> [ "USAGE", 		$RequestValues{Usage} ],
    XmitQName			=> [ "XMITQ", 		"string" ],

    QAttrs			=> [ "",		$RequestValues{QAttrs} ],

    #
    # These are specific to , and are not part of PCF (yet)
    #
    IndexType			=> [ "INDXTYPE",	$RequestValues{IndexType} ],
    StorageClass		=> [ "STGCLASS",	"string" ],

    ClusterName			=> [ "CLUSTER",		"string" ],
    ClusterNamelist		=> [ "CLUSNL",		"string" ],
    DefBind			=> [ "DEFBIND",		$RequestValues{DefBind} ],
    ClusInfo			=> [ "CLUSINFO" ],

   },

   InquireChannelNames =>
   {
    ChannelName			=> [ "CHANNEL",		"string" ],
    ChannelType 		=> [ "TYPE",		$RequestValues{ChannelType} ],
   },

   Channel =>
   {
    BatchInterval		=> [ "BATCHINT",       	"integer" ],
    BatchSize			=> [ "BATCHSZ",		"integer" ],
    ChannelAttrs 		=> [ "",		$RequestValues{ChannelAttrs} ],
    ChannelDesc			=> [ "DESCR",		"string" ],
    ChannelInstanceAttrs 	=> [ "",		$RequestValues{ChannelAttrs} ],
    ChannelInstanceType		=> [ "",		$RequestValues{ChannelInstanceType} ],
    ChannelName			=> [ "CHANNEL",		"string" ],
    ChannelTable		=> [ "CHLTABLE", 	$RequestValues{ChannelTable} ],
    ChannelType 		=> [ "CHLTYPE",		$RequestValues{ChannelType} ],
    ConnectionName		=> [ "CONNAME",		"string" ],
    DataConversion		=> [ "CONVERT",		$RequestValues{Yes} ],
    DataCount			=> [ "DATALEN",		"integer" ],
    DiscInterval		=> [ "DISCINT",		"integer" ],
    FromChannelName		=> [ "LIKE",		"string" ],
    HeartbeatInterval		=> [ "HBINT",		"integer" ],
    InDoubt 			=> [ "ACTION",		$RequestValues{InDoubt} ],
    InitiationQName 		=> [ "INITQ",		"string" ],
    LongRetryCount		=> [ "LONGRTY",		"integer" ],
    LongRetryInterval		=> [ "LONGTMR",		"integer" ],
    LUName			=> [ "LUNAME",		"string" ],
    MCAName			=> [ "MCANAME",		"string" ],
    MCAType			=> [ "MCATYPE",		$RequestValues{MCAType} ],
    MCAUserIdentifier		=> [ "MCAUSER",		"string" ],
    MaxMsgLength		=> [ "MAXMSGL",		"integer" ],
    ModeName			=> [ "MODENAME",      	"string" ],
    MsgExit			=> [ "MSGEXIT",		"string" ],
    MsgRetryCount		=> [ "MRRTY",		"integer" ],
    MsgRetryExit		=> [ "MREXIT",		"string" ],
    MsgRetryInterval		=> [ "MRTMR",		"integer" ],
    MsgRetryUserData		=> [ "MRDATA",		"string" ],
    MsgSeqNumber		=> [ "SEQNUM",		"integer" ],
    MsgUserData			=> [ "MSGDATA",		"string" ],
    NonPersistentMsgSpeed	=> [ "NPMSPEED",	$RequestValues{NonPersistentMsgSpeed} ],
    Password			=> [ "PASSWORD",	"string" ],
    Port			=> [ "PORT",		"integer" ],
    PutAuthority		=> [ "PUTAUT",		$RequestValues{PutAuthority} ],
    QMgrName			=> [ "QMNAME",		"string" ],
    Quiesce 			=> [ "MODE",		$RequestValues{Quiesce} ],
    ReceiveExit			=> [ "RCVEXIT",		"string" ],
    ReceiveUserData		=> [ "RCVDATA",		"string" ],
    Replace			=> [ "",		$RequestValues{Replace} ],
    SecurityExit		=> [ "SCYEXIT",		"string" ],
    SecurityUserData		=> [ "SCYDATA",		"string" ],
    SendExit			=> [ "SENDEXIT",	"string" ],
    SendUserData		=> [ "SENDDATA",	"string" ],
    SeqNumberWrap		=> [ "SEQWRAP",		"integer" ],
    ShortRetryCount		=> [ "SHORTRTY",	"integer" ],
    ShortRetryInterval		=> [ "SHORTTMR",	"integer" ],
    ToChannelName		=> [ "CHANNEL",		"string" ],
    TpName			=> [ "TPNAME",		"string" ],
    TransportType		=> [ "TRPTYPE",		$RequestValues{TransportType} ],
    UserIdentifier		=> [ "USERID",		"string" ],
    XmitQName			=> [ "XMITQ",		"string" ],

    #
    # These are specific to MVS
    #
    AutoStart			=> [ "AUTOSTART",	$RequestValues{Enabled} ],
    EnvironmentParamaters	=> [ "ENVPARM",		"string" ],
    Parameter			=> [ "PARM",		"string" ],
    
    #
    # New for 5.1/2.1
    #
    ClusterName			=> [ "CLUSTER",		"string" ],
    ClusterNamelist		=> [ "CLUSNL",		"string" ],
    NetworkPriority 		=> [ "NETPRTY",		"integer" ],

   },

   Namelist =>
   {
    NamelistName 		=> [ "NAMELIST",	"string" ],
    NamelistDesc		=> [ "DESCR",		"string" ],
    # XXX - this one may need special support for command-seperated lists
    Names 			=> [ "NAMES",		"string" ],

    Replace			=> [ "",		$RequestValues{Replace} ],
    
    FromNamelistName		=> [ "LIKE",		"string" ],
    ToNamelistName 		=> [ "NAMELIST",	"string" ],

    NamelistAttrs		=> [ "",		$RequestValues{NamelistAttrs} ],

   },

   Security =>
   {
    Interval			=> [ "INTERVAL",	"integer" ],
    Timeout			=> [ "TIMEOUT",		"integer" ],
    SecurityAttrs		=> [ "",		$RequestValues{SecurityAttrs} ],

    Admin			=> [ "MQADMIN" ],
    Namelist			=> [ "MQNLIST" ],
    Process			=> [ "MQPROC" ],
    Queue			=> [ "MQQUEUE" ],
    All				=> [ '*' ],

    UserIdentifier		=> [ "",		',' ],

   },

   StorageClass =>
   {
    StorageClassName		=> [ "STGCLASS",	"string" ],
    PageSetId			=> [ "PSID",		"integer" ],
    StorageClassDesc		=> [ "DESCR",		"string" ],
    XCFGroupName		=> [ "XCFGNAME",	"string" ],
    XCFMemberName		=> [ "XCFMNAME",	"string" ],

    FromStorageClassName	=> [ "LIKE",		"string" ],
    ToStorageClassName		=> [ "STGCLASS",	"string" ],

    Replace			=> [ "",		$RequestValues{Replace} ],

    StorageClassAttrs		=> [ "",		$RequestValues{StorageClassAttrs} ],

   },

   Trace =>
   {
    TraceType			=> [ "TRACE",		$RequestValues{TraceType} ],
    TraceNumber			=> [ "TNO",		"integer" ],
    Class			=> [ "CLASS",		"integer" ],
    Comment			=> [ "COMMENT",		"string" ],
    EventId			=> [ "IFCID",		"string" ],
    Destination			=> [ "DEST",		"string" ],
    ResourceMgrId		=> [ "RMID",		"integer" ],
    UserIdentifier		=> [ "USERID",		"string" ],
    TraceData			=> [ "TDATA",		$RequestValues{TraceData} ],
   },

   ArchiveLog =>
   {
    Quiesce 			=> [ "MODE",		$RequestValues{Quiesce} ],
    Time			=> [ "TIME",		"integer" ],
    Wait			=> [ "WAIT",		$RequestValues{Yes} ],
   },

   BufferPool =>
   {
    BufferPool			=> [ "BUFFPOOL",	"integer" ],
    Buffers			=> [ "BUFFERS",		"integer" ],
   },

   PageSetId =>
   {
    PageSetId			=> [ "PSID",		"integer" ],
    BufferPool			=> [ "BUFFPOOL",	"integer" ],
   },

   Cluster =>
   {
    ClusterQMgrName 		=> [ "CLUSQMGR",	"string" ],
    Channel			=> [ "CHANNEL",		"string" ],
    ClusterName			=> [ "CLUSTER", 	"string" ],
    ClusterQMgrAttrs		=> [ "",		$RequestValues{ClusterQMgrAttrs} ],
    ClusterNamelist		=> [ "CLUSNL",		"string" ],
    Quiesce 			=> [ "MODE",		$RequestValues{Quiesce} ],
    QMgrName			=> [ "QMNAME",		"string" ],
    Action			=> [ "ACTION",		$RequestValues{ClusterAction} ],
   },

   Tpipe =>
   {
    TpipeName			=> [ "TPIPE",		"string" ],
    Action			=> [ "ACTION",		$RequestValues{TpipeAction} ],
    SendSequence		=> [ "SENDSEQ",		"integer" ],
    ReceiveSequence		=> [ "RCVSEQ",		"integer" ],
    XCFGroupName		=> [ "XCFGNAME",	"string" ],
   },
   
   InquireThread =>
   {
    ThreadName			=> [ "THREAD",		"string" ],
    ThreadType			=> [ "TYPE",		$RequestValues{ThreadType} ],
   },

   ResolveInDoubt =>
   {
    InDoubt			=> [ "INDOUBT",		"string" ],
    Action			=> [ "ACTION",		$RequestValues{InDoubtAction} ],
    NetworkId			=> [ "NID",		"string" ],
   },

  );

$RequestParameters{CreateQueue} = $RequestParameters{ChangeQueue} = $RequestParameters{DeleteQueue} =
  {
   %{$RequestParameters{Queue}},
   QName			=> [ $RequestParameterRemap{Queue},	"string" ],
  };

$RequestParameters{CopyQueue} =
  {
   %{$RequestParameters{Queue}},
   ToQName			=> [ $RequestParameterRemap{Queue},	"string" ],
  };

$RequestParameters{ClearQueue} =
  {
   %{$RequestParameters{Queue}},
   QName			=> [ "QLOCAL",		"string" ],
  };

1;
