#
# $Id: RequestParameters.pl,v 23.2 2003/04/10 19:09:43 biersma Exp $
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%RequestParameters =
  (

   #
   # These parameters are used to update specific queue manager
   # attributes ("ALTER QMGR"), and specify how the values are
   # encoded.  A related list in RequestValues.pl specifies the
   # attributes that can be inquired ("DISPLAY QMGR").
   #
   QueueManager =>
   {
    AuthorityEvent		=> [ "AUTHOREV", 	$RequestValues{Enabled} ],
    ChannelAutoDef		=> [ "CHAD",		$RequestValues{Enabled} ],
    ChannelAutoDefEvent		=> [ "CHADEV",		$RequestValues{Enabled} ],
    ChannelAutoDefExit 		=> [ "CHADEXIT",	"string" ],
    ClusterWorkLoadExit		=> [ "CLWLEXIT",	"string" ],
    ClusterWorkLoadData		=> [ "CLWLDATA",	"string" ],
    ClusterWorkLoadLength	=> [ "CLWLLEN",		"string" ],
    CodedCharSetId		=> [ "CCSID",		"integer" ],
    ConfigurationEvent          => [ "CONFIGEV",        $RequestValues{Enabled} ],
    DeadLetterQName		=> [ "DEADQ", 		"string" ],
    DefXmitQName		=> [ "DEFXMITQ",	"string" ],
    ExpiryInterval              => [ "EXPRYINT",        "string" ], # OFF / Number
    Force			=> [ "FORCE" ],
    InhibitEvent		=> [ "INHIBTEV",	$RequestValues{Enabled} ],
    IntraGroupAuthority         => [ "IGQAUT",          $RequestValues{IntraGroupAuthority} ],
    IntraGroupQueueing          => [ "IGQ",             $RequestValues{Enabled} ], 
    IntraGroupUser              => [ "IGQUSER",         "string" ],
    LocalEvent			=> [ "LOCALEV",		$RequestValues{Enabled} ],
    MaxHandles			=> [ "MAXHANDS", 	"integer" ],
    MaxMsgLength		=> [ "MAXMSGL",		"integer" ],
    MaxUncommittedMsgs		=> [ "MAXUMSGS", 	"integer" ],
    PerformanceEvent		=> [ "PERFMEV",		$RequestValues{Enabled} ],
    QMgrDesc			=> [ "DESCR", 		"string" ],
    QMgrAttrs			=> [ "",		$RequestValues{QMgrAttrs} ],
    QSharingGroupDisposition    => [ "QSGDISP",         $RequestValues{QSharingGroupDisposition} ],
    RemoteEvent			=> [ "REMOTEEV",	$RequestValues{Enabled} ],
    RepositoryName 		=> [ "REPOS",		"string" ],
    RepositoryNamelist		=> [ "REPOSNL",		"string" ],
    SSLCRLNamelist              => [ "SSLCRLNL",        "string" ],
    SSLKeyRepository            => [ "SSLKEYR",         "string" ],
    SSLTasks                    => [ "SSLTASKS",        "integer" ],
    StartStopEvent		=> [ "STRSTPEV",	$RequestValues{Enabled} ],
    TriggerInterval		=> [ "TRIGINT", 	"integer" ],
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
    QSharingGroupDisposition    => [ "QSGDISP",         $RequestValues{QSharingGroupDisposition} ],
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
    CouplingStructure           => [ "CFSTRUCT",        "string" ],
    DefInputOpenOption		=> [ "DEFSOPT",		$RequestValues{DefInputOpenOption} ],
    DefPersistence		=> [ "DEFPSIST",	$RequestValues{Yes} ],
    DefPriority			=> [ "DEFPRTY", 	"integer" ],
    DefinitionType		=> [ "DEFTYPE", 	$RequestValues{DefinitionType} ],
    DistLists			=> [ "DISTL",		$RequestValues{Yes} ],
    Force			=> [ "FORCE" ],
    FromQName			=> [ "LIKE",		"string" ],
    HardenGetBackout		=> [ "", 		$RequestValues{HardenGetBackout} ],
    InhibitGet			=> [ "GET", 		$RequestValues{Disabled} ],
    InhibitPut			=> [ "PUT",		$RequestValues{Disabled} ],
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
    QSharingGroupDisposition    => [ "QSGDISP",         $RequestValues{QSharingGroupDisposition} ],
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
    # These are specific to MQSC, and are not part of PCF (yet)
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

   #
   # These parameters are used to defined or update specific channel
   # attributes ("DEFINE CHANNEL", "ALTER CHANNEL"), and specify how
   # the values are encoded.  A related list in RequestValues.pl
   # specifies the attributes that can be inquired ("DISPLAY CHANNEL").
   #
   Channel =>
   {
    AutoStart			=> [ "AUTOSTART",	$RequestValues{Enabled} ],
    BatchHeartBeat              => [ "BATCHHB",         "integer" ],
    BatchInterval		=> [ "BATCHINT",       	"integer" ],
    BatchSize			=> [ "BATCHSZ",		"integer" ],
    ChannelAttrs 		=> [ "",		$RequestValues{ChannelAttrs} ],
    ChannelDesc			=> [ "DESCR",		"string" ],
    ChannelDisposition          => [ "CHLDISP",         $RequestValues{ChannelDisposition} ],
    ChannelInstanceAttrs 	=> [ "",		$RequestValues{ChannelAttrs} ],
    ChannelInstanceType		=> [ "",		$RequestValues{ChannelInstanceType} ],
    ChannelName			=> [ "CHANNEL",		"string" ],
    ChannelTable		=> [ "CHLTABLE", 	$RequestValues{ChannelTable} ],
    ChannelType 		=> [ "CHLTYPE",		$RequestValues{ChannelType} ],
    ClusterName			=> [ "CLUSTER",		"string" ],
    ClusterNamelist		=> [ "CLUSNL",		"string" ],
    CommandScope                => [ "CMDSCOPE",        "string" ],
    ConnectionName		=> [ "CONNAME",		"string" ],
    DataConversion		=> [ "CONVERT",		$RequestValues{Yes} ],
    DataCount			=> [ "DATALEN",		"integer" ],
    DiscInterval		=> [ "DISCINT",		"integer" ],
    EnvironmentParameters	=> [ "ENVPARM",		"string" ],
    FromChannelName		=> [ "LIKE",		"string" ],
    HeartbeatInterval		=> [ "HBINT",		"integer" ],
    InDoubt 			=> [ "ACTION",		$RequestValues{InDoubt} ],
    InitiationQName 		=> [ "INITQ",		"string" ],
    LongRetryCount		=> [ "LONGRTY",		"integer" ],
    LongRetryInterval		=> [ "LONGTMR",		"integer" ],
    KeepAliveInterval           => [ "KAINT",           "integer" ],
    LocalAddress                => [ "LOCLADDR",        "string" ],
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
    NetworkPriority 		=> [ "NETPRTY",		"integer" ],
    NonPersistentMsgSpeed	=> [ "NPMSPEED",	$RequestValues{NonPersistentMsgSpeed} ],
    Parameter			=> [ "PARM",		"string" ],
    Password			=> [ "PASSWORD",	"string" ],
    Port			=> [ "PORT",		"integer" ],
    PutAuthority		=> [ "PUTAUT",		$RequestValues{PutAuthority} ],
    QMgrName			=> [ "QMNAME",		"string" ],
    QSharingGroupDisposition    => [ "QSGDISP",         $RequestValues{QSharingGroupDisposition} ],
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
    SSLCipherSpec               => [ "SSLCIPH",         "string" ],
    SSLClientAuth               => [ "SSLCAUTH",        $RequestValues{SSLClientAuth} ],
    SSLPeerName                 => [ "SSLPEER",         "string" ],
    ToChannelName		=> [ "CHANNEL",		"string" ],
    TpName			=> [ "TPNAME",		"string" ],
    TransportType		=> [ "TRPTYPE",		$RequestValues{TransportType} ],
    UserIdentifier		=> [ "USERID",		"string" ],
    XmitQName			=> [ "XMITQ",		"string" ],
   },

   Namelist =>
   {
    NamelistName 		=> [ "NAMELIST",	"string" ],
    NamelistDesc		=> [ "DESCR",		"string" ],
    NamelistType                => [ "NLTYPE",          $RequestValues{NamelistType} ],
    # XXX - this one may need special support for comma-separated lists
    Names 			=> [ "NAMES",		"string" ],

    Replace			=> [ "",		$RequestValues{Replace} ],
    
    CommandScope                => [ "CMDSCOPE",        "string" ],
    FromNamelistName		=> [ "LIKE",		"string" ],
    QSharingGroupDisposition    => [ "QSGDISP",         $RequestValues{QSharingGroupDisposition} ],
    ToNamelistName 		=> [ "NAMELIST",	"string" ],

    NamelistAttrs		=> [ "",		$RequestValues{NamelistAttrs} ],

   },

   InquireQueueStatus =>
   {
    QName                       => [ "QSTATUS",         "string" ],
    CommandScope                => [ "CMDSCOPE",        "string" ],
    StatusType                  => [ "TYPE",            $RequestValues{StatusType} ],
    OpenType                    => [ "OPENTYPE",        $RequestValues{OpenType} ],
    QStatusAttrs                => [ "",                $RequestValues{QStatusAttrs} ],
   },

   ResetQueueStatistics =>
   {
    QName                       => [ "QSTATS",          "string" ],
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

   InquireStorageClassNames =>
   {
    StorageClassName		=> [ "STGCLASS",	"string" ],
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

   #
   # These parameters are used to defined or update specific AuthInfo
   # attributes ("DEFINE AUTHINFO", "ALTER AUTHINFO"), and specify how
   # the values are encoded.  A related list in RequestValues.pl
   # specifies the attributes that can be inquired ("DISPLAY AUTHINFO").
   #
   AuthInfo =>
   {
    AuthInfoConnName            => [ "CONNAME",         "string" ],
    AuthInfoDesc                => [ "DESCR",           "string" ],
    AuthInfoName                => [ "AUTHINFO",        "string" ],
    AuthInfoType                => [ "AUTHTYPE",        $RequestValues{AuthInfoType} ],
    LDAPPassword                => [ "LDAPPWD",         "string" ],
    LDAPUserName                => [ "LDAPUSER",        "string" ],
    AuthInfoAttrs               => [ "",                $RequestValues{AuthInfoAttrs} ],
   },


   #
   # These parameters are used to defined or update specific CF Structure
   # attributes ("DEFINE CFSTRUCT", "ALTER CFSTRUCT"), and specify how
   # the values are encoded.  A related list in RequestValues.pl
   # specifies the attributes that can be inquired ("DISPLAY CFSTRUCT").
   #
   CFStruct =>
   {
    CFStructDesc                => [ "DESCR",           "string", ],
    CFStructLevel               => [ "CFLEVEL",         "integer" ],
    CFStructName                => [ "CFSTRUCT",        "string" ],
    Recovery                    => [ "RECOVER",         $RequestValues{Yes} ],
    CFStructAttrs               => [ "",                $RequestValues{CFStructAttrs} ],
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

$RequestParameters{CreateQueue} = $RequestParameters{ChangeQueue} =
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

$RequestParameters{DeleteQueue} =
  {
   %{$RequestParameters{Queue}},
   QName			=> [ $RequestParameterRemap{Queue},	"string" ],
   Purge			=> [ "",		$RequestValues{Purge} ],
  };


1;
