#
# $Id: RequestValues.pl,v 24.1 2003/11/03 16:32:02 biersma Exp $
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%RequestValues =
  (

   Yes				=> [ "NO",		"YES" ],

   Enabled 			=> [ "DISABLED",	"ENABLED" ],

   Disabled 			=> [ "ENABLED",	        "DISABLED" ],

   HardenGetBackout		=> [ "NOHARDENBO",	"HARDENBO" ],

   Purge                        => [ "NOPURGE",         "PURGE" ],

   Shareability			=> [ "NOSHARE",		"SHARE" ],

   TriggerControl		=> [ "NOTRIGGER",	"TRIGGER" ],

   Quiesce			=> [ "FORCE", 		"QUIESCE" ],

   Replace			=> [ "NOREPLACE",	"REPLACE" ],

   #
   # These parameters are used to determine what attributes must be
   # returned by a "display queue manager" command.  The default for
   # an InquireQueueManager() command is "All".
   #
   QMgrAttrs =>
   {
    All				=> "ALL",
    AlterationDate              => "ALTDATE",
    AlterationTime              => "ALTTIME",
    AuthorityEvent		=> "AUTHOREV",
    ChannelAutoDef		=> "CHAD",
    ChannelAutoDefEvent		=> "CHADEV",
    ChannelAutoDefExit		=> "CHADEXIT",
    ClusterWorkLoadData		=> "CLWLDATA",
    ClusterWorkLoadExit		=> "CLWLEXIT",
    ClusterWorkLoadLength	=> "CLWLLEN",
    CodedCharSetId		=> "CCSID",
    CommandInputQName		=> "COMMANDQ",
    CommandLevel		=> "CMDLEVEL",
    ConfigurationEvent          => "CONFIGEV",
    DeadLetterQName		=> "DEADQ",
    DefXmitQName		=> "DEFXMITQ",
    DistLists			=> "DISTL",
    ExpiryInterval              => "EXPRYINT",
    InhibitEvent		=> "INHIBTEV",
    LocalEvent			=> "LOCALEV",
    MaxHandles			=> "MAXHANDS",
    MaxMsgLength		=> "MAXMSGL",
    MaxPriority			=> "MAXPRTY",
    MaxUncommittedMsgs		=> "MAXUMSGS",
    PerformanceEvent		=> "PERFMEV",
    Platform			=> "PLATFORM",
    QMgrDesc			=> "DESCR",
    QMgrIdentifier		=> "QMID",
    QMgrName			=> "QMNAME",
    RemoteEvent			=> "REMOTEEV",
    RepositoryName		=> "REPOS",
    RepositoryNamelist		=> "REPOSNL",
    SSLCRLNamelist              => "SSLCRLNL",
    SSLKeyRepository            => "SSLKEYR",
    SSLTasks                    => "SSLTASKS",
    StartStopEvent		=> "STRSTPEV",
    SyncPoint			=> "SYNCPT",
    TriggerInterval		=> "TRIGINT",
   },

   #
   # These parameters are used to determine what attributes must be
   # returned by a "display queue" command.  The default for an
   # InquireQueue() command is "All".
   #
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
    IndexType			=> "INDXTYPE",
    InhibitGet			=> "GET",
    InhibitPut			=> "PUT",
    InitiationQName		=> "INITQ",
    MaxMsgLength		=> "MAXMSGL",
    MaxQDepth			=> "MAXDEPTH",
    MsgDeliverySequence		=> "MSGDLVSQ",
    OpenInputCount		=> "IPPROCS",
    OpenOutputCount		=> "OPPROCS",
    PageSetId                   => "PSID",
    ProcessName			=> "PROCESS",
    QDepthHighEvent		=> "QDPHIEV",
    QDepthHighLimit		=> "QDEPTHHI",
    QDepthLowEvent		=> "QDPLOEV",
    QDepthLowLimit		=> "QDEPTHLO",
    QDepthMaxEvent		=> "QDPMAXEV",
    QDesc			=> "DESCR",
    QName                       => "",
    QServiceInterval		=> "QSVCINT",
    QServiceIntervalEvent 	=> "QSVCIEV",
    QSharingGroupDisposition    => "QSGDISP",
    QType			=> "QTYPE",
    RemoteQMgrName		=> "RQMNAME",
    RemoteQName			=> "RNAME",
    RetentionInterval		=> "RETINTVL",
    Scope 			=> "SCOPE",
    Shareability		=> "SHARE",
    StorageClass		=> "STGCLASS",
    TriggerControl		=> "TRIGGER",
    TriggerData			=> "TRIGDATA",
    TriggerDepth		=> "TRIGDPTH",
    TriggerMsgPriority		=> "TRIGMPRI",
    TriggerType			=> "TRIGTYPE",
    Usage			=> "USAGE",
    XmitQName			=> "XMITQ",
   },

   #
   # These parameters are used to determine what attributes must be
   # returned by a "display auth info" command.  The default for an
   # InquireAuthInfo() command is "All".
   #
   AuthInfoAttrs =>
   {
    All				=> "ALL",
    AlterationDate              => "ALTDATE",
    AlterationTime              => "ALTTIME",
    AuthInfoConnName            => "CONNAME",
    AuthInfoDesc                => "DESCR",
    AuthInfoType                => "AUTHTYPE",
    LDAPPassword                => "LDAPPWD",
    LDAPUserName                => "LDAPUSER",
   },

   AuthInfoType =>
   {
    CRLLDAP                     => "CRLLDAP",
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
    QSharingGroupDisposition    => "QSGDISP",
    UserData			=> "USERDATA",

    AlterationDate		=> "ALTDATE",
    AlterationTime		=> "ALTTIME",
   },

   ChannelDisposition =>
   {
    All                         => "ALL",
    Private                     => "PRIVATE",
    Shared                      => "SHARED",
   },

   DefInputOpenOption =>
   {
    Exclusive			=> "EXCL",
    Shared			=> "SHARED",
   },

   DefinitionType =>
   {
    Permanent			=> "PERMDYN",
    Shared			=> "SHAREDYN",
    Temporary			=> "TEMPDYN",
   },

   IndexType =>
   {
    CorrelId			=> "CORRELID",
    MsgToken			=> "MSGTOKEN",
    MsgId			=> "MSGID",
    None			=> "NONE",
   },

   IntraGroupAuthority =>
   {
    AltIGQ                      => "ALTIGQ",
    Context                     => "CTX",
    Default                     => "DEF",
    OnlyIGQ                     => "ONLYIGQ",
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

   QSharingGroupDisposition =>
   {
    All                         => "ALL",
    Copy                        => "COPY",
    Group                       => "GROUP",
    Live                        => "LIVE",
    Private                     => "PRIVATE",
    QMgr                        => "QMGR",
    Shared                      => "SHARED",
   },

   Scope =>
   {
    QMgr			=> "QMGR",
    Cell			=> "CELL",
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
    AlternateMCA                => "ALTMCA",
    OnlyMCA                     => "ONLYMCA",
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

   #
   # These parameters are used to determine what attributes must be
   # returned by a "display channel" command.  The default for an
   # InquireChannel() command is "All".
   #
   ChannelAttrs =>
   {
    All				=> "ALL",
    AlterationDate		=> "ALTDATE",
    AlterationTime		=> "ALTTIME",
    BatchHeartBeat              => "BATCHHB",
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
    ClusterName 		=> "CLUSTER",
    ClusterNamelist		=> "CLUSNL",
    ConnectionName		=> "CONNAME",
    CurrentLUWID		=> "CURLUWID",
    CurrentMsgs			=> "CURMSGS",
    CurrentSequenceNumber	=> "CURSEQNO",
    DataConversion		=> "CONVERT",
    DiscInterval		=> "DISCINT",
    HeartbeatInterval		=> "HBINT",
    InDoubtStatus		=> "INDOUBT",
    KeepAliveInterval           => "KAINT",
    LastLUWID			=> "LSTLUWID",
    LastMsgDate			=> "LSTMSGDA",
    LastMsgTime			=> "LSTMSGTI",
    LastSequenceNumber		=> "LSTSEQNO",
    LocalAddress                => "LOCLADDR",
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
    QSharingGroupDisposition    => "QSGDISP",
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
    SSLCipherSpec               => "SSLCIPH",
    SSLClientAuth               => "SSLCAUTH",
    SSLPeerName                 => "SSLPEER",
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
    NamelistType                => "NLTYPE",
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
    All                         => "ALL",
    AlterationDate		=> "ALTDATE",
    AlterationTime 		=> "ALTTIME",
    PageSetId                   => "PSID",
    QSharingGroupDisposition    => "QSGDISP",
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

   StatusType =>
   {
    Queue                       => "QUEUE",
    Handle                      => "HANDLE",
   },

   OpenType =>
   {
    All                         => "ALL",
    Input                       => "INPUT",
    Output                      => "OUTPUT",
   },

   SSLClientAuth =>
   {
    Optional                    => "OPTIONAL",
    Required                    => "REQUIRED",
   },

   QStatusAttrs =>
   {
    All                         => "ALL",
    AddressSpaceId              => "ASID",
    ApplTag                     => "APPLTAG",
    ApplType                    => "APPLTYPE",
    ChannelName                 => "CHANNEL",
    Conname                     => "CONNAME",
    CurrentQDepth               => "CURDEPTH",
    OpenInputCount              => "IPPROCS",
    OpenOutputCount             => "OPPROCS",
    PSBName                     => "PSBNAME",
    PSTId                       => "PSTID",
    QName                       => "QNAME",
    QSharingGroupDisposition    => "QSGDISP",
    TaskNumber                  => "TASKNO",
    TransactionId               => "TRANSID",
    UncommittedMsgs             => "UNCOM",
    URId                        => "URID",
    UserIdentifier              => "USERID",
   },

   #
   # These parameters are used to determine what attributes must be
   # returned by a "display CF Structure" command.  The default for an
   # InquireCfStruct() command is "All".
   #
   CFStructAttrs =>
   {
    All                         => "ALL",
    AlterationDate		=> "ALTDATE",
    AlterationTime		=> "ALTTIME",
    CFStructDesc                => "DESCR",
    CFStructLevel               => "CFLEVEL",
    Recovery                    => "RECOVER",
   },

   NamelistType =>
   {
    None                        => "NONE",
    Queue                       => "QUEUE",
    Cluster                     => "CLUSTER",
    AuthInfo                    => "AUTHINFO",
   },


  );

1;
