#
# $Id: RequestValues.pl,v 14.1 2000/08/15 20:51:36 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%RequestValues =
  (

   Yes				=> [ "NO",		"YES" ],

   Enabled 			=> [ "DISABLED",	"ENABLED" ],

   HardenGetBackout		=> [ "NOHARDENBO",	"HARDENBO" ],

   Shareability			=> [ "NOSHARE",		"SHARE" ],

   TriggerControl		=> [ "NOTRIGGER",	"TRIGGER" ],

   Quiesce			=> [ "FORCE", 		"QUIESCE" ],

   Replace			=> [ "NOREPLACE",	"REPLACE" ],

   QMgrAttrs =>
   {
    All				=> "ALL",
    QMgrName			=> "QMNAME",
    QMgrDesc			=> "DESCR",
    Platform			=> "PLATFORM",
    CommandLevel		=> "CMDLEVEL",
    TriggerInterval		=> "TRIGINT",
    DeadLetterQName		=> "DEADQ",
    MaxPriority			=> "MAXPRTY",
    CommandInputQName		=> "COMMANDQ",
    DefXmitQName		=> "DEFXMITQ",
    CodedCharSetId		=> "CCSID",
    MaxHandles			=> "MAXHANDS",
    MaxUncommittedMsgs		=> "MAXUMSGS",
    MaxMsgLength		=> "MAXMSGL",
    DistLists			=> "DISTL",
    SyncPoint			=> "SYNCPT",
    AuthorityEvent		=> "AUTHOREV",
    InhibitEvent		=> "INHIBTEV",
    LocalEvent			=> "LOCALEV",
    RemoteEvent			=> "REMOTEEV",
    StartStopEvent		=> "STRSTPEV",
    PerformanceEvent		=> "PERFMEV",
    ChannelAutoDef		=> "CHAD",
    ChannelAutoDefEvent		=> "CHADEV",
    ChannelAutoDefExit		=> "CHADEXIT",

    ClusterWorkLoadExit		=> "CLWLEXIT",
    ClusterWorkLoadData		=> "CLWLDATA",
    ClusterWorkLoadLength	=> "CLWLLEN",
    QMgrIdentifier		=> "QMID",
    RepositoryName		=> "REPOS",
    RepositoryNamelist		=> "REPOSNL",

   },

   QAttrs =>
   {
    All				=> "ALL",
    BackoutRequeueName		=> "BOQNAME",
    BackoutThreshold		=> "BOTHRESH",
    BaseQName			=> "TARGQ",
    CreationDate		=> "CRDATE",
    CreationTime		=> "CRTIME",
    CurrentQDepth		=> "CURDEPTH",
    DefInputOpenOption		=> "DEFSOPT",
    DefPersistence		=> "DEFPSIST",
    DefPriority			=> "DEFPRTY",
    DefinitionType		=> "DEFTYPE",
    DistLists			=> "DISTL",
    HardenGetBackout		=> "HARDENBO",
    InhibitGet			=> "GET",
    InhibitPut			=> "PUT",
    InitiationQName		=> "INITQ",
    MaxMsgLength		=> "MAXMSGL",
    MaxQDepth			=> "MAXDEPTH",
    MsgDeliverySequence		=> "MSGDLVSQ",
    ProcessName			=> "PROCESS",
    QDepthHighEvent		=> "QDPHIEV",
    QDepthHighLimit		=> "QDEPTHHI",
    QDepthLowEvent		=> "QDPLOEV",
    QDepthLowLimit		=> "QDEPTHLO",
    QDepthMaxEvent		=> "QDPMAXEV",
    QDesc			=> "DESCR",
    QServiceInterval		=> "QSVCINT",
    QServiceIntervalEvent 	=> "QSVCIEV",
    QType			=> "TYPE",
    RemoteQMgrName		=> "RQMNAME",
    RemoteQName			=> "RNAME",
    RetentionInterval		=> "RETINTVL",
    Scope 			=> "SCOPE",
    Shareability		=> "SHARE",
    TriggerControl		=> "TRIGGER",
    TriggerData			=> "TRIGDATA",
    TriggerDepth		=> "TRIGDPTH",
    TriggerMsgPriority		=> "TRIGMPRI",
    TriggerType			=> "TRIGTYPE",
    Usage			=> "USAGE",
    XmitQName			=> "XMITQ",
    OpenInputCount		=> "IPPROCS",
    OpenOutputCount		=> "OPPROCS",

    #
    # These are specific to MQSC, and are not part of PCF (yet)
    #
    IndexType			=> "INDXTYPE",
    StorageClass		=> "STGCLASS",

   },

   ApplType =>
   {
    AIX				=> "UNIX",
    CICS			=> "CICS",
    DOS				=> "DOS",
    Default			=> "DEF",
    IMS				=> "IMS",
    NSK				=> "NSK",
    MVS				=> "MVS",
    OS2				=> "OS2",
    OS400			=> "OS400",
    UNIX			=> "UNIX",
    VMS				=> "VMS",
    Win16			=> "WINDOWS",
    Win32			=> "WINDOWSNT",
   },

   ProcessAttrs =>
   {
    All				=> "ALL",
    ProcessName			=> "PROCESS",
    ProcessDesc			=> "DESCR",
    ApplType			=> "APPLTYPE",
    ApplId			=> "APPLICID",
    EnvData			=> "ENVRDATA",
    UserData			=> "USERDATA",

    AlterationDate		=> "ALTDATE",
    AlterationTime		=> "ALTTIME",
   },

   Scope =>
   {
    QMgr			=> "QMGR",
    Cell			=> "CELL",
   },

   DefInputOpenOption =>
   {
    Exclusive			=> "EXCL",
    Shared			=> "SHARED",
   },

   MsgDeliverySequence =>
   {
    Priority			=> "PRIORITY",
    FIFO			=> "FIFO",
   },

   QServiceIntervalEvent =>
   {
    High			=> "HIGH",
    None			=> "NONE",
    OK				=> "OK",
   },

   TriggerType =>
   {
    None			=> "NONE",
    Every			=> "EVERY",
    First			=> "FIRST",
    Depth			=> "DEPTH",
   },

   Usage =>
   {
    Normal			=> "NORMAL",
    XMITQ			=> "XMITQ",
   },

   DefinitionType =>
   {
    Predefined			=> "",
    Permanent			=> "PERMDYN",
    Temporary			=> "TEMPDYN",
   },

   IndexType =>
   {
    CorrelId			=> "CORRELID",
    MsgToken			=> "MSGTOKEN",
    MsgId			=> "MSGID",
    None			=> "NONE",
   },

   QType =>
   {
    Local			=> "QLOCAL",
    Remote			=> "QREMOTE",
    Alias			=> "QALIAS",
    Model			=> "QMODEL",
   },

   ChannelType =>
   {
    Sender			=> "SDR",
    Server			=> "SVR",
    Receiver			=> "RCVR",
    Requester			=> "RQSTR",
    Svrconn			=> "SVRCONN",
    Clntconn			=> "CLNTCONN",
    ClusterReceiver		=> "CLUSRCVR",
    ClusterSender		=> "CLUSSDR",
   },

   MCAType =>
   {
    Process			=> "PROCESS",
    Thread			=> "THREAD",
   },

   NonPersistentMsgSpeed =>
   {
    Normal			=> "NORMAL",
    Fast			=> "FAST",
   },

   PutAuthority =>
   {
    Default			=> "DEF",
    Context			=> "CTX",
   },

   InDoubt =>
   {
    Commit			=> "COMMIT",
    Backout			=> "BACKOUT",
   },

   TransportType =>
   {
    LU62			=> "LU62",
    UDP				=> "UDP",
    TCP				=> "TCP",
    SPX				=> "SPX",
    NetBIOS			=> "NETBIOS",
    DECNET			=> "DECNET",
   },

   ChannelTable =>
   {
    QMgr			=> "QMGRTBL",
    Clntconn			=> "CLNTTBL",
   },

   ChannelInstanceType =>
   {
    Current			=> "CURRENT",
    Saved			=> "SAVED",
   },

   ChannelAttrs =>
   {
    All				=> "ALL",
    AlterationDate		=> "ALTDATE",
    AlterationTime		=> "ALTTIME",
    ClusterName 		=> "CLUSTER",
    ClusterNamelist		=> "CLUSNL",
    BatchInterval		=> "BATCHINT",
    BatchSize			=> "BATCHSZ",
    Batches			=> "BATCHES",
    BuffersReceived		=> "BUFSRCVD",
    BuffersSent			=> "BUFSSENT",
    BytesReceived		=> "BYTSRCVD",
    BytesSent			=> "BYTSSENT",
    ChannelDesc			=> "DESCR",
    ChannelInstanceType		=> "CHLTYPE",
    ChannelName			=> "",
    ChannelNames		=> "",
    ChannelStartDate		=> "CHSTADA",
    ChannelStartTime		=> "CHSTATI",
    ChannelStatus		=> "",
    ChannelType			=> "CHLTYPE",
    ConnectionName		=> "CONNAME",
    CurrentLUWID		=> "CURLUWID",
    CurrentMsgs			=> "CURMSGS",
    CurrentSequenceNumber	=> "CURSEQNO",
    DataConversion		=> "CONVERT",
    DiscInterval		=> "DISCINT",
    HeartbeatInterval		=> "HBINT",
    InDoubtStatus		=> "INDOUBT",
    LastLUWID			=> "LSTLUWID",
    LastMsgDate			=> "LSTMSGDA",
    LastMsgTime			=> "LSTMSGTI",
    LastSequenceNumber		=> "LSTSEQNO",
    LongRetriesLeft		=> "LONGRTS",
    LongRetryCount		=> "LONGRTY",
    LongRetryInterval		=> "LONGTMR",
    MCAJobName			=> "JOBNAME",
    MCAName			=> "MCANAME",
    MCAStatus			=> "MCASTAT",
    MCAType			=> "MCATYPE",
    MCAUserIdentifier		=> "MCAUSER",
    MaxMsgLength		=> "MAXMSGL",
    ModeName			=> "MODENAME",
    MsgExit			=> "MSGEXIT",
    MsgRetryCount		=> "MRRTY",
    MsgRetryExit		=> "MREXIT",
    MsgRetryInterval		=> "MRTMR",
    MsgRetryUserData		=> "MRDATA",
    MsgUserData			=> "MSGDATA",
    Msgs			=> "MSGS",
    NonPersistentMsgSpeed	=> "NPMSPEED",
    Password			=> "PASSWORD",
    PutAuthority		=> "PUTAUT",
    QMgrName			=> "QMNAME",
    ReceiveExit			=> "RCVEXIT",
    ReceiveUserData		=> "RCVDATA",
    SecurityExit		=> "SCYEXIT",
    SecurityUserData		=> "SCYDATA",
    SendExit			=> "SENDEXIT",
    SendUserData		=> "SENDDATA",
    SeqNumberWrap		=> "SEQWRAP",
    ShortRetriesLeft		=> "SHORTRTS",
    ShortRetryCount		=> "SHORTRTY",
    ShortRetryInterval		=> "SHORTTMR",
    StopRequested		=> "STOPREQ",
    TpName			=> "TPNAME",
    TransportType		=> "TRPTYPE",
    UserIdentifier		=> "USERID",
    XmitQName			=> "XMITQ",
   },

   DefBind =>
   {
    OnOpen			=> "OPEN",
    NotFixed			=> "NOTFIXED",
   },

   NamelistAttrs =>
   {
    All				=> "ALL",
    NamelistName 		=> "NAMELIST",
    NamelistDesc		=> "DESCR",
    Names			=> "NAMES",
    AlterationDate		=> "ALTDATE",
    AlterationTime 		=> "ALTTIME",
    NamelistCount		=> "NAMCOUNT",
   },

   SecurityAttrs =>
   {
    Interval			=> "INTERVAL",
    Switches			=> "SWITCHES",
    Timeout			=> "TIMEOUT",
   },

   StorageClassAttrs =>
   {
    AlterationDate		=> "ALTDATE",
    AlterationTime 		=> "ALTTIME",
    StorageClassDesc		=> "DESCR",	
    XCFGroupName		=> "XCFGNAME",
    XCFMemberName		=> "XCFMNAME",
   },

   TraceType =>
   {
    All				=> '*',
    Global			=> "GLOBAL",
    Statistical			=> "STAT",
    Accounting			=> "ACCTG",
   },

   TraceData =>
   {
    Correlation			=> "CORRELATION",
    Trace			=> "TRACE",
   },

   ClusterQMgrAttrs =>
   {
    All				=> "ALL",
    AlterationDate		=> "ALTDATE",
    AlterationTime		=> "ALTTIME",
    BatchInterval		=> "BATCHINT",
    BatchSize			=> "BATCHSZ",
    ChannelDesc			=> "DESCR",
    ChannelName			=> "CHANNEL",
    ChannelStatus		=> "STATUS",
    ClusterDate			=> "CLUSDATE",
    ClusterName 		=> "CLUSTER",
    ClusterTime			=> "CLUSTIME",
    ConnectionName		=> "CONNAME",
    DataConversion		=> "CONVERT",
    DiscInterval		=> "DISCINT",
    HeartbeatInterval		=> "HBINT",
    LongRetryCount		=> "LONGRTY",
    LongRetryInterval		=> "LONGTMR",
    MCAName			=> "MCANAME",
    MCAType			=> "MCATYPE",
    MCAUserIdentifier		=> "MCAUSER",
    MaxMsgLength		=> "MAXMSGL",
    ModeName			=> "MODENAME",
    MsgExit			=> "MSGEXIT",
    MsgRetryCount		=> "MRRTY",
    MsgRetryExit		=> "MREXIT",
    MsgRetryInterval		=> "MRTMR",
    MsgRetryUserData		=> "MRDATA",
    MsgUserData			=> "MSGDATA",
    NetworkPriority 		=> "NETPRTY",
    NonPersistentMsgSpeed    	=> "NPMSPEED",
    Password			=> "PASSWORD",
    PutAuthority		=> "PUTAUT",
    QMgrDefinitionType		=> "DEFTYPE",
    QMgrIdentifier		=> "QMID",
    QMgrType			=> "QMTYPE",
    ReceiveExit			=> "RCVEXIT",
    ReceiveUserData		=> "RCVDATA",
    SecurityExit		=> "SCYEXIT",
    SecurityUserData		=> "SCYDATA",
    SendExit			=> "SENDEXIT",
    SendUserData		=> "SENDDATA",
    SeqNumberWrap		=> "SEQWRAP",
    ShortRetryCount		=> "SHORTRTY",
    ShortRetryInterval		=> "SHORTTMR",
    Suspend			=> "SUSPEND",
    TpName			=> "TPNAME",
    TransportType		=> "TRPTYPE",
    UserIdentifier		=> "USERID",
   },

   ClusterAction =>
   {
    ForceRemove			=> "FORCEREMOVE",
   },

   TpipeAction =>
   {
    Commit			=> "COMMIT",
    Backout			=> "BACKOUT",
   },

   ThreadType =>
   {
    Active			=> "ACTIVE",
    InDoubt			=> "INDOUBT",
    All				=> '*',
   },

   InDoubtAction =>
   {
    Commit			=> "COMMIT",
    Backout			=> "BACKOUT",
   },

  );

1;
