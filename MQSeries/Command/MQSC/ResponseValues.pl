#
# $Id: ResponseValues.pl,v 13.3 2000/03/23 21:11:46 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

package MQSeries::Command::MQSC;

%ResponseValues =
  (
   Enabled =>
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

   DefInputOpenOption =>
   {
    EXCL    		=> "Exclusive",
    SHARED    		=> "Shared",
   },

   DefinitionType =>
   {
    PREDEFINED 		=> "Predefined",
    PERMDYN	    	=> "Permanent",
    TEMPDYN	    	=> "Temporary",
   },

   MsgDeliverySequence =>
   {
    PRIORITY		=> "Priority",
    FIFO		=> "FIFO",
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
   },

   TransportType =>
   {
    LU62    		=> "LU62",
    TCP    		=> "TCP",
    NETBIOS    		=> "NetBIOS",
    SPX    		=> "SPX",
   },

   ApplType =>
   {
    MVS 		=> "MVS",
    IMS 		=> "IMS",
    VMS 		=> "VMS",
    OS400		=> "OS400",
    OS2 		=> "OS2",
    WINDOWSNT    	=> "Win32",
    DOS    		=> "DOS",
    WINDOWS    		=> "Win16",
    UNIX    		=> "UNIX",
    CICS    		=> "CICS",
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

 );

1;
