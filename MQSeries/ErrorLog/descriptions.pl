# 
# descriptions.pl - Include file for MQSeries::ErrorLog::Parser
#                   that describes all known error types.
#
# (c) 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
# 
# $Id: descriptions.pl,v 15.1 2000/11/13 23:18:45 wpm Exp $
#

#
# For more info on all these messages, see the
# IBM MQSeries Messages manual, GC33-1876.
#

package MQSeries::ErrorLog::Parser;

use strict;
use vars qw($error_table);

#
# Define a set of helper-patterns
#
my $channel_patt = '[\w\.\%\/]+';
my $code_patt = '-?\d+';
my $exit_patt = '/[\w\.\/\-\(\)]+';
my $hex_patt = '[A-F\d]+';
my $hostname_patt = '[\w\-]+';
my $ip_patt = '\d+\.\d+\.\d+\.\d+';
my $host_patt = "$hostname_patt \\($ip_patt\\) \\(\\d+\\)|$hostname_patt \\($ip_patt\\)|$ip_patt \\(\\d+\\)|$ip_patt";
my $pid_patt = '\d+';
my $qmgr_patt = '[\w\.!%\/]+';
my $qname_patt = '[\w\.\%\/]+';
my $rc_patt = '\d+';
my $reason_patt = '\d+: \(.*?\)|\d+:\w+|\d+\w+|\d+:?';
my $resourcemgr_patt = '\w+\s+\w+';
my $xa_operation_patt = 'xa_\w+';
my $seqno_patt = '\d+';

#
# NOTE: Keep this table in alphabetical order for ease of maintenance
#
$error_table = 
  { 

   #
   # Messages AMQ3500-3999 are MQSeries for Windows.
   # So far, we don't support them.
   #

   # 
   # Messages AMQ4000-4999 are MQSeries for Windows NT 
   # user-interface messages.  We don't support these.
   #

   #
   # Messages AMQ5000-5999 are Installable Services Messages
   #

   'AMQ5008' => [ "An essential MQSeries process ($pid_patt) cannot be found and is assumed to be terminated\\.",
                  "Pid" ],

   'AMQ5009' => [ "MQSeries agent process ($pid_patt) has terminated unexpectedly\\.",
                  "Pid" ],

   'AMQ5511' => [ "Installable service component '(.*?)' returned 'CompCode = ($rc_patt), Reason = ($rc_patt)'\\.",
                  "Component", "Code", "Reason" ],

   'AMQ5520' => [ "The system could not load the module '(.*?)' for the installable service '(.*?)' component '(.*?)'\\. The system return code was ($rc_patt)\\. The Queue Manager is continuing without this component\\.",
                  "Module", "Service", "Component", "Code" ],

   'AMQ5806' => [ "MQSeries message broker started for queue manager ($qmgr_patt)\\.",
                  "QMgr" ],

   'AMQ5807' => [ "MQSeries message broker for queue manager ($qmgr_patt) ended\\.",
                  "QMgr" ],

   'AMQ5817' => [ "An invalid stream queue \\(($qname_patt)\\s*\\) has been detected by the MQSeries message broker\\.",
                  "Stream" ],

   # FIXME: So far, encountered this guy without an actual broker name...
   'AMQ5818' => [ "Unable to open MQSeries message broker stream queue \\(\\) for reason 0,0" ],

   'AMQ5819' => [ "MQSeries message broker stream \\(($qname_patt)\\s*\\) has ended abnormally for reason ($reason_patt)\\.",
                  "Stream", "Reason" ],

   'AMQ5820' => [ "MQSeries message broker stream \\(\\s*($qname_patt)\\s*\\) restarted.",
                  "Stream" ],
   
   'AMQ5821' => [ "MQSeries message broker unable to contact parent broker \\(($qmgr_patt) \\) for reason ($reason_patt)\\.",
                  "Broker", "Reason" ],

   'AMQ5822' => [ "MQSeries message broker failed to register as a child of broker \\(($qmgr_patt) \\) for reason ($reason_patt)\\. .* The problem is likely to be caused by the parent broker not yet existing, or a problem with the ($qname_patt) queue at the parent broker\\.",
                  "Broker", "Reason", "QName" ],

   'AMQ5832' => [ "MQSeries message broker failed to publish configuration information on ($qname_patt)\\.",
                  "QName" ],

   # FIXME: So far, encountered this guy without an actual broker name...
   'AMQ5839' => [ "MQSeries message broker received unexpected inter-broker communication from broker \(\)" ],

   'AMQ5840' => [ "MQSeries message broker unable to delete queue \\(($qname_patt)\\s*\\) for reason ($reason_patt)\\.",
                  "QName", "Reason" ],

   'AMQ5841' => [ "MQSeries message broker \\(($qmgr_patt)\\) deleted.",
                  "Broker" ],

   'AMQ5842' => [ "MQSeries message broker \\(($qmgr_patt)\\) cannot be deleted for reason '($reason_patt)'\\.",
                  "Broker", "Reason" ],

   # FIXME: So far, enountered this guy without an actual relation name...
   'AMQ5844' => [ "MQSeries message broker relation \\(\\) is unknown to broker \\(($qmgr_patt)\\)\\.",
                  "Broker" ],

   'AMQ5847' => [ "MQSeries message broker \\(($qmgr_patt)\\) has removed knowledge of relation \\(($qmgr_patt)\\)\\.",
                  "Broker", "Relation" ],

   # FIXME: So far, enountered this guy without an actual relation name...
   'AMQ5848' => [ "MQSeries message broker \\(($qmgr_patt)\\) has failed to remove references to relation \\(\\) for reason '($reason_patt)'\\.",
                  "Broker", "Reason" ],

   'AMQ5849' => [ "MQSeries message broker \\(($qmgr_patt) \\) may not change parent from \\(($qmgr_patt) \\) to \\(($qmgr_patt) \\)\\.",
                  "Broker", "OldParent", "NewParent" ],

   'AMQ5855' => [ "MQSeries message broker \\(($qmgr_patt)\\) ended for reason '($reason_patt)'\\.",
                  "Broker", "Reason" ],

   'AMQ5856' => [ "Broker publish command message cannot be processed\\. Reason code ($reason_patt)\\..* The MQSeries broker failed to process a publish message for stream \\(($qname_patt)\\s*\\)\\.",
                  "Reason", "Stream" ],

   'AMQ5857' => [ "Broker control command message cannot be processed\\. Reason code ($reason_patt)\\..*The MQSeries broker failed to process a command message on the ($qname_patt)\\.",
                  "Reason", "Stream" ],

   'AMQ5864' => [ "Broker reply message could not be sent to queue \\(($qname_patt)\\s*\\) at queue manager \\(($qmgr_patt)\\s*\\) for reason ($reason_patt)\\.",
                  "Stream", "QMgr", "Reason" ],

   'AMQ5866' => [ "Broker command message has been discarded\\. Reason code ($reason_patt)\\.",
                  "Reason" ],

   'AMQ5867' => [ " MQSeries message broker stream \\(($qname_patt)\\s*\\) has ended abnormally for reason ($reason_patt)\\.",
                  "Stream", "Reason" ],

   'AMQ5878' => [ "MQSeries message broker recovery failure detected\\." ],
     
   # NOTE: The 'Stream' field here may look like 'uncreated stream',
   #       hence not match the qname_pattern normally used.
   'AMQ5882' => [ "The MQSeries message broker has written a message to the dead-letter queue \\(($qname_patt)\\s*\\) for reason '($reason_patt)'.*for stream \\((.*?)\\s*\\)",
                   "DeadletterQueue", "Reason", "Stream" ],

   # 
   # Messages AMQ6000-6999 are Common Services Messages
   # Many of these (all?) should have a corresponding entry in the FDC logs.
   #

   'AMQ6047' => [ "MQSeries is unable to convert string data tagged in CCSID \\d+ to data in CCSID \\d+\\." ],

   'AMQ6050' => [ "MQSeries is unable to convert string data in CCSID \\d+ to data in CCSID \\d+\\." ],

   'AMQ6053' => [ "MQSeries is unable to convert string data in CCSID \\d+ to data in CCSID -?\\d+\\." ],

   'AMQ6090' => [ "MQSeries was unable to display an error message" ],

   'AMQ6091' => [ "An internal MQSeries error has occurred\\." ],

   'AMQ6109' => [ "An internal MQSeries error has occurred\\." ],

   'AMQ6110' => [ "An internal MQSeries error has occurred\\." ],

   'AMQ6118' => [ "An internal MQSeries error has occurred" ],

   'AMQ6119' => [ "An internal MQSeries error has occurred" ],

   'AMQ6122' => [ "An internal MQSeries error has occurred\\." ],
   
   'AMQ6125' => [ "An internal error has occurred with identifier ($hex_patt)\\.",
                  "Id" ],

   'AMQ6150' => [ "MQSeries semaphore is busy" ], 

   'AMQ6162' => [ "An error has occurred reading an INI file\\." ],

   'AMQ6175' => [ "The system could not dynamically load the library ($exit_patt)",
                  "Exit" ],

   'AMQ6183' => [ "The failing process is process ($pid_patt)\\.",
                  "Pid" ],

   'AMQ6188' => [ "The system could not dynamically load the shared library '($exit_patt)' due to a problem with the library",
                  "Exit" ],

   'AMQ6184' => [ "An internal MQSeries error has occurred on queue manager ($qmgr_patt)\\..*The failing process is process ($pid_patt)\\.",
                  "QMgr", "Pid" ],

   # NOTE: So far, encountered this error without a location.
   'AMQ6708' => [ "A disk full condition was encountered when formatting a new log file in location (.*?)\\.",
                  "Location" ],

   # 
   # Messages AMQ7000-7999 are MQSeries Product Messages
   #
   'AMQ7030' => [ "Request to quiesce the queue manager accepted\\." ],

   'AMQ7075' => [ "Unknown attribute (\\S+) on line (\\d+) of ini file (\\S+)\\.",
                  "Attribute", "Line", "File" ],

   'AMQ7076' => [ "Line (\\d+) of the configuration file (\\S+) contained value (.*?)\s*that is not valid for the attribute (\\S+)\\.",
                  "Line", "File", "Value", "Attribute" ],

   'AMQ7159' => [ "A FASTPATH application has ended unexpectedly" ],

   'AMQ7310' => [ "The attempt to put a report message on queue ($qname_patt) on queue manager ($qmgr_patt) failed with reason code ($reason_patt)\\. The message will be put on the dead-letter queue\\.",
                  "QName", "QMgr", "Reason" ],

   'AMQ7463' => [ "The log for queue manager ($qmgr_patt) is full\\.",
                  "QMgr" ],

   'AMQ7469' => [ "Transactions rolled back to release log space\\." ],

   'AMQ7472' => [ "Object ($qname_patt), type (\\w+) damaged\\.",
                  "Object", "Type" ],

   'AMQ7604' => [ "The XA resource manager '($resourcemgr_patt)' was not available when called for ($xa_operation_patt)\\.",
                  "ResourceMgr", "Operation" ],

   'AMQ7605' => [ "The XA resource manager ($resourcemgr_patt) has returned an unexpected return code ($code_patt), when called for ($xa_operation_patt)\\.",
                  "ResourceMgr", "Code", "Operation" ],

   'AMQ7622' => [ "MQSeries could not load the XA switch load file for resource manager '($resourcemgr_patt)'\\..*?An error has occurred loading XA switch file (.*?)\\. If the error",
                  "ResourceMgr", "File" ],

   'AMQ7624' => [ "An exception occurred during an ($xa_operation_patt) call to XA resource manager '($resourcemgr_patt)'\\.",
                  "Operation", "ResourceMgr" ],

   'AMQ7625' => [ "The XA resource manager '($resourcemgr_patt)' has become available again\\.",
                  "ResourceMgr" ],

   'AMQ7924' => [ "Bad length in the PCF header \\(length = \\d+\\)\\." ],

   # FIXME: If encountered again, determine message version pattern
   'AMQ7925' => [ "Message version 16777216 is not supported" ],

   # FIXME: If encountered again, determine CCSID pattern
   'AMQ7935' => [ "Bad CCSID in message header \\(CCSID = 0\\)" ],

   # 
   # Messages AMQ8000-8999 are MQSeries Administration Messages
   #

   'AMQ8003' => [ "MQSeries queue manager '?($qmgr_patt)'? started\\.",
                  "QMgr" ],

   'AMQ8004' => [ "MQSeries queue manager ($qmgr_patt) ended\\.",
                  "QMgr" ],

   # FIXME: Are the number of objects of interest?
   'AMQ8048' => [ "Default objects statistics :" ],

   'AMQ8226' => [ "MQSeries channel ($channel_patt) cannot be created",
                  "Channel" ],

   'AMQ8424' => [ "Error detected in a name keyword\\." ],

   'AMQ8504' => [ "An MQINQ request by the command server, for the MQSeries queue ($qname_patt), failed with reason code ($reason_patt)\\.",
                  "QName", "Reason" ],

   'AMQ8506' => [ "An MQGET request by the command server, for the MQSeries queue ($qname_patt), failed with reason code ($reason_patt)\\.",
                  "QName", "Reason" ],

   'AMQ8507' => [ "failed with reason code ($reason_patt)\\. The MQDLH reason code was ($reason_patt)\\.",
                  "Mqput1Code", "MqdlhCode" ],

   'AMQ8508' => [ "A request by the command server to delete a queue manager object list failed with return code ($reason_patt)\\.",
                "Reason" ],

   'AMQ8509' => [ "Command server MQCLOSE reply-to queue failed with reason code ($reason_patt)\\.",
                 "Reason" ],
   
   # 
   # Messages AMQ9000-9999 are Remote Messages
   #
   'AMQ9001' => [  "Channel program '($channel_patt)' ended normally",
                   "Channel" ],
   
   'AMQ9002' => [  "Channel program '($channel_patt)' started",
                   "Channel" ],

   'AMQ9184' => [ "The user exit '(\\S+)' returned an address '0' for the exit buffer that is not valid",
                  "Exit" ],
   
   # FIXME: Nasty, we also encounter this message in a completely
   #        different format.
   'AMQ9202' => [  "Remote host '($host_patt)' not available.*from TCP/IP is ($rc_patt) \\(X'",
                  'Host', 'IPCode' ],

   # FIXME: Encountered this without a host name, check...
   'AMQ9203' => [ "A configuration error for TCP/IP occurred" ],
   
   'AMQ9206' => [  "over TCP/IP to '?($host_patt)'?.*from (?:the )?TCP/IP(?:\\(write\\) call was| is) ($rc_patt) X\\('",
                  'Host', 'IPCode' ],

   'AMQ9207' => [ "Incorrect data format received from host '($host_patt)' over TCP/IP",
                  'Host' ],
   
   'AMQ9208' => [ "receiving data from '?($host_patt)'?.*return code (?:from the TCP/IP \\((.*?)\\) call was )?($rc_patt) \\(X'",
                  'Host', 'Operation', 'IPCode' ],
   
   'AMQ9209' => [ "An error occurred receiving data from '($host_patt)' over TCP/IP\\.", 
                  'Host' ],

   'AMQ9213' => [ "The return code from the TCP/IP \\((.*?)\\) call was ($rc_patt) \\(X'", 
                  "Operation", "IPCode" ],

   'AMQ9221' => [ " The specified value of '(.*?)' was not recognized as one of the protocols supported\\.",
                  "Protocol" ],
   
   'AMQ9228' => [ "The TCP/IP responder program could not be started\\." ],

   'AMQ9245' => [ "MQSeries was unable to obtain the account details for MCA user ID '(\\w+)'\\. This user ID was the MCA user ID for channel '($channel_patt)' on queue manager '($qmgr_patt)' and may have been defined in the channel definition, or supplied either by a channel exit or by a client\\.",
                  "Userid", "Channel", "QMgr" ],

   'AMQ9410' => [ "The repository manager started successfully\\." ],

   'AMQ9411' => [ "The repository manager (?:ended|stopped) normally\\." ],

   'AMQ9447' => [ "Following an error, the repository manager tried to backout some updates to the repository, but was unsuccessful\\. The repository manager terminates\\." ],


   # NOTE: At time, this gets invalid channel names (eg, from bad clients),
   #       so we use a non-standard pattern
   'AMQ9503' => [ "Channel '(.*?)' between this machine and the remote machine could not be established",
                  "Channel" ],

   'AMQ9504' => [ "A protocol error was detected for channel '($channel_patt)'\\.",
                  "Channel" ],
   
   'AMQ9506' => [ "Channel '($channel_patt)' has ended because the remote queue manager did not accept the last batch of messages.",
                  "Channel" ],

   'AMQ9507' => [ "Channel '($channel_patt)' is currently in-doubt\\. .* The requested operation cannot complete because the channel is in-doubt with host '(.*?)'\\.",
                  "Channel", "Host" ],

   # NOTE: At times, this gets empty queue manager names (probably
   #       a client error), so we use a non-standard pattern
   'AMQ9508' => [ "The connection attempt to queue manager '(.*?)' failed with reason code ($reason_patt)\\.",
                  "QMgr", "Reason" ],

   'AMQ9509' => [ "The attempt to open either the queue or queue manager object '(.*?)' on queue manager '($qmgr_patt)' failed with reason code ($reason_patt)\\.",
                  "Object", "QMgr", "Reason" ],

   'AMQ9510' => [ "The attempt to get messages from queue '($qname_patt)' on queue manager '($qmgr_patt)' failed with reason code ($reason_patt)\\.",
                  "QName", "QMgr", "Reason" ],

   'AMQ9511' => [ "The attempt to put messages to queue '($qname_patt)' on queue manager '($qmgr_patt)' failed with reason code ($reason_patt)\\.",
                  "QName", "QMgr", "Reason" ],

   'AMQ9514' => [ "Channel '($channel_patt)' is in use",
                  "Channel" ],

   'AMQ9516' => [ "The filesystem returned error code ($code_patt) for file '(.*?)'\\.",
                  "Code", "Filename" ],

   'AMQ9518' => [ "File '($exit_patt)' not found",
                  "Exit" ],

   # NOTE: At times, this gets invalid channel names (eg, from bad clients),
   #       so we use a non-standard pattern
   'AMQ9519' => [ "The requested operation failed because the program could not find a definition of channel '(.*?)'\\.",
                   "Channel" ],
   
   'AMQ9520' => [ "There is no definition of channel '($channel_patt)' at the remote location\\.",
                   "Channel" ],

   'AMQ9522' => [ "The program could not access the channel status table\\." ],
   
   'AMQ9524' => [ "Channel '($channel_patt)' cannot start because the remote queue manager is not currently available\\.",
                  "Channel" ],
   
   'AMQ9525' => [ "Channel '($channel_patt)' is closing",
                  "Channel" ],
   
   'AMQ9526' => [ "error for channel '($channel_patt)'.*A message with sequence number ($seqno_patt) has been sent when sequence number ($seqno_patt) was",
                  "Channel", "sent_seqno", "expected_seqno" ],

   'AMQ9527' => [ "Cannot send message through channel '($channel_patt)'\\.",
                  "Channel" ],
   
   'AMQ9528' => [ "User requested closure of channel '($channel_patt)'\\.",
                  "Channel" ],

   'AMQ9530' => [ "The attempt to inquire the attributes of queue '($qname_patt)' on queue manager '($qmgr_patt)' failed with reason code ($reason_patt)\\.",
                  "QName", "QMgr", "Reason" ],

   'AMQ9531' => [ "Queue '($qname_patt)' identified as a transmission queue in the channel definition '($channel_patt)' is not a transmission queue\\.",
                  "QName", "Channel" ],

   'AMQ9533' => [ "Channel '($channel_patt)' is not currently active\\.",
                  "Channel" ],
   
   'AMQ9534' => [ "Channel '($channel_patt)' is currently",
                  "Channel" ],

   'AMQ9535' => [ "Channel program '($channel_patt)' ended because user exit '(.*?)' is not valid\\.",
                  "Channel", "Exit" ],

   'AMQ9536' => [ "Channel program '($channel_patt)' was ended by exit '($exit_patt)'",
                  "Channel", "Exit" ],

   'AMQ9542' => [ "Queue manager is ending\\." ],

   'AMQ9544' => [ "During the processing of channel '($channel_patt)' one or more.*The program identifier \\(PID\\) of the processing program was '($pid_patt)'\\.",
                  "Channel", "Pid" ],
   
   'AMQ9545' => [ "Channel '($channel_patt)' closed because",
                  "Channel" ],

   'AMQ9547' => [ "The operation requested cannot be performed because channel '($channel_patt)' on the remote machine is not of a suitable type\\.",
                  "Channel" ],
   
   'AMQ9549' => [ "Transmission Queue '($qname_patt)' inhibited for MQGET\\.",
                  "QName" ],

   'AMQ9553' => [ "The function (.*?) attempted is not currently supported on this platform\\.",
                  "Function" ],

   'AMQ9558' => [ "The channel program ended because the channel '($channel_patt)' is not currently available on the remote system\\.",
                  "Channel" ],

   'AMQ9588' => [ "Program cannot update queue manager object\\..*The attempt to update object '(.*?)' on queue manager '($qmgr_patt)' failed with reason code ($reason_patt)\\.",
                  "Object", "QMgr", "Reason" ],

   # NOTE: Found this with an empty user id
   'AMQ9599' => [ "The attempt to open either the queue or queue manager object '($qname_patt)' on queue manager '($qmgr_patt)' by user '.*?' failed with reason code ($reason_patt)\\.",
                  "QName", "QMgr", "Reason" ],
                     
   # NOTE: At times, this gets invalid channel names (eg, from bad clients),
   #       so we use a non-standard pattern
   'AMQ9999' => [ "Channel program '(.*?)' ended abnormally\\.",
                  "Channel" ],
   
  };

1;                              # End on a positive note
