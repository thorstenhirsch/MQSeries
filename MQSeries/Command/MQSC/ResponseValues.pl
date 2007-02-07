#
# $Id: ResponseValues.pl,v 27.8 2007/01/11 20:20:05 molinam Exp $
#
# (c) 1999-2007 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%ResponseValues =
  (
   ActivityRecording =>	       
   {
    DISABLED                   => "Disabled",
    MSG                        => "Msg",
    QUEUE                      => "Queue",
   },

   Disabled =>                  # InhibitGet/InhbitPut have reversed logic
   {
    DISABLED		=> 1,
    ENABLED		=> 0,
   },

   Enabled =>                   # Everyone else with enabled/disabled
   {
    DISABLED		=> 0,
    ENABLED		=> 1,
   },

   Yes =>
   {
    NO			=> 0,
    YES			=> 1,
   },

   OnOff =>
   {
    OFF			=> "Off",
    ON			=> "On",
   },

   AdoptNewMCACheck =>
   {
    ALL			=> "All",
    NETADDR		=> "NetworkAddress",
    NONE		=> "None",
    QMNAME		=> "QMgrName",
   },

   AdoptNewMCAType =>
   {
    ALL			=> "All",
    NO			=> "No",
   },

   Available =>
   {
    UNAVAILABLE		=> 0,
    AVAILABLE		=> 1,
   },

   ChannelDisposition =>
   {
    ALL                 => "All",
    PRIVATE             => "Private",
    SHARED              => "Shared",
   },

   ChannelEvent =>
   {
    DISABLED           => "Disabled",
    ENABLED            => "Enabled",
    EXCEPTION          => "Exception",
   },

   ChannelMonitoring =>
   {
    HIGH                       => "High",
    LOW			       => "Low",
    MEDIUM		       => "Medium",
    NONE                       => "None",
    OFF			       => "Off",
   },

   ClusterSenderMonitoringDefault =>
   {
    HIGH			=> "High",
    LOW				=> "Low",
    MEDIUM			=> "Medium",
    QMGR                        => "QMgr",
    OFF				=> "Off",
   },

   CLWLUseQ =>
   {
    ANY    		=> "Any",
    LOCAL    		=> "Local",
    QMGR    		=> "QMgr", # Only returned by queue CLWLUseQ
   },

   CommandEvent =>
   {
    DISABLED           => "Disabled",
    ENABLED            => "Enabled",
    NODISPLAY          => "NoDisplay",
   },

   DefInputOpenOption =>
   {
    EXCL    		=> "Exclusive",
    SHARED    		=> "Shared",
   },

   DefinitionType =>
   {
    PREDEFINED 		=> "Predefined",
    PERMDYN	    	=> "Permanent",
    SHAREDYN		=> "Shared",
    TEMPDYN	    	=> "Temporary",
   },

   IGQPutAuthority =>
   {
    ALTIGQ              => "AltIGQ",
    CTX                 => "Context",
    DEF                 => "Default",
    ONLYIGQ             => "OnlyIGQ",
   },

   IPAddressVersion =>
   {
    IPV4		=> "IPv4",
    IPV6		=> "IPv6",
   },

   MonitoringDft =>
   {
    OFF                         => "Off",
    QMGR                        => "QMgr",
    LOW                         => "Low",
    MEDIUM                      => "Medium",
    HIGH                        => "High",
   },

   MsgDeliverySequence =>
   {
    PRIORITY		=> "Priority",
    FIFO		=> "FIFO",
   },

   NonPersistentMsgClass =>
   {
    HIGH		=> "High",
    NORMAL		=> "Normal",
   },

   QMgrAccounting =>	      # QMgr-level QueueAccounting
   {
    NONE                       => "None",
    ON                         => "On",
    OFF                        => "Off",
   },

   QueueAccounting =>
   {
    OFF			=> "Off",
    ON			=> "On",
    QMGR		=> "QMgr",
   },

   QSGDisposition =>
   {
    COPY                => "Copy",
    GROUP               => "Group",
    PRIVATE             => "Private",
    QMGR                => "QMgr",
    SHARED              => "Shared",
   },

   QServiceIntervalEvent =>
   {
    HIGH    		=> "High",
    OK    		=> "OK",
    NONE    		=> "None",
   },

   QType =>
   {
    QALIAS    		=> "Alias",
    QLOCAL    		=> "Local",
    QREMOTE    		=> "Remote",
    QMODEL    		=> "Model",
   },

   ReceiveTimeoutType =>
   {
    ADD    		=> "Add",
    EQUAL    		=> "Equal",
    MULTIPLY   		=> "Multiply",
   },

   Scope =>
   {
    CELL    		=> "Cell",
    QMGR    		=> "QMgr",
   },

   SharedQQmgrName =>
   {
    IGNORE   		=> "Ignore",
    USE   		=> "Use",
   },

   TCPStackType =>
   {
    MULTIPLE   		=> "Multiple",
    SINGLE   		=> "Single",
   },

   TraceRouteRecording =>
   {
    DISABLED   		=> "Disabled",
    MSG   		=> "Msg",
    QUEUE   		=> "Queue",
   },

   TriggerType =>
   {
    NONE    		=> "None",
    EVERY    		=> "Every",
    FIRST    		=> "First",
    DEPTH    		=> "Depth",
   },

   Usage =>
   {
    NORMAL    		=> "Normal",
    XMITQ    		=> "XMITQ",
   },

   KeepAliveInterval =>
   {
    AUTO    		=> "Auto",
   },

   ChannelStatus =>
   {
    BINDING		=> "Binding",
    INITIALIZING 	=> "Initializing",
    # Special spelling for OS/390 :-(
    INITIALIZI	 	=> "Initializing",
    PAUSED 		=> "Paused",
    REQUESTING 		=> "Requesting",
    RETRYING 		=> "Retrying",
    RUNNING 		=> "Running",
    STARTING		=> "Starting",
    STOPPED 		=> "Stopped",
    STOPPING 		=> "Stopping",
    INACTIVE		=> "Inactive",
   },

   MCAType =>
   {
    PROCESS    		=> "Process",
    THREAD    		=> "Thread",
   },

   MCAStatus =>
   {
    "STOPPED"		=> "Stopped",
    "RUNNING"		=> "Running",
   },

   NonPersistentMsgSpeed =>
   {
    NORMAL    		=> "Normal",
    FAST    		=> "Fast",
   },

   PutAuthority =>
   {
    DEF    		=> "Default",
    CTX    		=> "Context",
    ONLYMCA             => "OnlyMCA",
    ALTMCA              => "AlternateMCA",
   },

   TransportType =>
   {
    DECNET    		=> "DECNET",
    LU62    		=> "LU62",
    NETBIOS    		=> "NetBIOS",
    SPX    		=> "SPX",
    TCP    		=> "TCP",
    UDP    		=> "UDP",
   },

   ApplType =>
   {
    BATCH               => "Batch",
    CHINIT              => "Channel Initiator",
    CICS    		=> "CICS",
    DOS    		=> "DOS",
    IMS 		=> "IMS",
    MVS 		=> "MVS",
    NSK                 => "NSK",
    OS400		=> "OS400",
    OS2 		=> "OS2",
    RRSBATCH            => "RRS-Batch",
    SYSTEM              => "Queue Manager",
    UNIX    		=> "UNIX",
    USER                => "User Application",
    VMS 		=> "VMS",
    WINDOWS    		=> "Win16",
    WINDOWSNT    	=> "Win32",
   },

   ClusterQType =>
   {
    QALIAS 		=> "Alias",
    QLOCAL 		=> "Local",
    QMGR 		=> "QMgrAlias",
    QREMOTE 		=> "Remote",
   },

   DefBind =>
   {
    OPEN		=> "OnOpen",
    NOTFIXED		=> "NotFixed",
   },

   ChannelType =>
   {
    SDR			=> "Sender",
    SVR			=> "Server",
    RCVR		=> "Receiver",
    RQSTR		=> "Requester",
    SVRCONN		=> "Svrconn",
    CLNTCONN		=> "Clntconn",
    CLUSRCVR		=> "ClusterReceiver",
    CLUSSDR		=> "ClusterSender",
   },

   Compression =>
   {
    NONE		=> "None",
    SYSTEM		=> "System",
   },

   MessageCompression =>
   {
    ANY				=> "Any",
    NONE			=> "None",
    RLE				=> "Rle",
    ZLIBFAST			=> "ZlibFast",
    ZLIBHIGH			=> "ZlibHigh",
   },

   TraceType =>
   {
    GLOBAL		=> "Global",
    STAT		=> "Statistical",
    ACCTG		=> "Accounting",
   },

   QMgrDefinitionType =>
   {
    CLUSSDR		=> "ExplicitClusterSender",
    CLUSSDRA 		=> "AutoClusterSender",
    CLUSSDRB 		=> "AutoExplicitClusterSender",
    CLUSRCVR		=> "ClusterReceiver",
   },

   QMgrType =>
   {
    NORMAL		=> "Normal",
    REPOS               => "Repository",
   },

   IndexType =>
   {
    CORRELID		=> "CorrelId",
    GROUPID             => "GroupId",
    MSGTOKEN		=> "MsgToken",
    MSGID		=> "MsgId",
    NONE		=> "None",
   },

   StatusType =>
   {
    HANDLE              => "Handle",
    QUEUE               => "Queue",
   },

   QStatusInputType =>
   {
    EXCL                => "Exclusive",
    NO                  => "No",
    SHARED              => "Shared",
   },

   SSLClientAuth =>
   {
    OPTIONAL            => "Optional",
    REQUIRED            => "Required",
   },

   AuthInfoType =>
   {
    CRLLDAP             => "CRLLDAP",
   },

   NamelistType =>
   {
    NONE                => "None",
    QUEUE               => "Queue",
    Q                   => "Queue",
    CLUSTER             => "Cluster",
    AUTHINFO            => "AuthInfo",
   },

   QMgrMonitoring =>
   {
    HIGH			=> "High",
    LOW				=> "Low",
    MEDIUM			=> "Medium",
    NONE                        => "None",
    OFF				=> "Off",
   },

   QueueMonitoring =>
   {
    HIGH			=> "High",
    LOW				=> "Low",
    MEDIUM			=> "Medium",
    QMGR                        => "QMgr",
    OFF				=> "Off",
   },
   TraceRouteRecording =>	       
   {
    DISABLED                   => "Disabled",
    MSG                        => "Msg",
    QUEUE                      => "Queue",
   },

 );

#
# These parameter names changed from the guess in MQSeries 1.23 and
# before and the PCF name in 1.24 and later.  Add this for backwards
# compatibility.
#
$ResponseValues{IntraGroupAuthority} = $ResponseValues{IGQPutAuthority};
$ResponseValues{QSharingGroupDisposition} = $ResponseValues{QSGDisposition};

1;
