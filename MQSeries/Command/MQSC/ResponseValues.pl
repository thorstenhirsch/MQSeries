#
# $Id: ResponseValues.pl,v 24.1 2003/11/03 16:36:47 biersma Exp $
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%ResponseValues =
  (
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

   IntraGroupAuthority =>
   {
    ALTIGQ              => "AltIGQ",
    CTX                 => "Context",
    DEF                 => "Default",
    ONLYIGQ             => "OnlyIGQ",
   },

   MsgDeliverySequence =>
   {
    PRIORITY		=> "Priority",
    FIFO		=> "FIFO",
   },

   QSharingGroupDisposition =>
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

   Scope =>
   {
    QMGR    		=> "QMgr",
    CELL    		=> "Cell",
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

 );

1;
