#
# WARNING: This file is automatically generated.
# Any changes made here will be mercilessly lost.
#
# You have been warned, infidel.
#
# P.S. For the real source to this file, see:
#
#    ..../src/pre.in/MQSeries/Message/ConfigEvent.in
#
# and for the evil hackery used to generate this, see:
#
#    ..../src/util/flatten_macros
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#
package MQSeries::Message::ConfigEvent;

%ResponseParameters =
  (
   #
   # These are unqiue for PCF v2 events
   #
   7001                                  => 'EventAccountingToken',
   3049                                  => 'EventApplIdentity',
   3050                                  => 'EventApplName',
   3051                                  => 'EventApplOrigin',
   1010                                  => 'EventApplType',
   1011                                  => 'EventOrigin',
   3047                                  => 'EventQMgr',
   3045                                  => 'EventUserid',

   #
   # This is necesary to translate the object type, so we can
   # look up most keys in PCF command structures.
   #
   1016                                  => 'ObjectType',

   #
   # The below do not have PCF command equivalents on Unix.  We might
   # want to add them to the PCF response parameter tables...
   #
   2027                                  => 'AlterationDate',
   2028                                  => 'AlterationTime',
   2052                                  => 'CFStructDesc',
   2039                                  => 'CFStructName',
   2041                                  => 'IntraGroupUser',
   2040                                  => 'QSharingGroupName',
   2022                                  => 'StorageClassName',

   70                                    => 'CFStructLevel',
   71                                    => 'Recovery',
   39                                    => 'ExpiryInterval',
   65                                    => 'IntraGroupAuthority',
   57                                    => 'IndexType',
   64                                    => 'IntraGroupQueueing',
   62                                    => 'PageSetId',
   63                                    => 'QSharingGroupDisposition',
   69                                    => 'SSLTasks',
   2043                                  => 'XCFGroupName',
   2044                                  => 'XCFMemberName',

   1566                                  => 'KeepAliveInterval',
  );


#
# We only include enums that we either need to get the object type, or
# that would not be included in the normal PCF command set.
#
%ResponseEnums =
  (

   EventOrigin =>
   {
    1                    => "MQEVO_CONSOLE - Console",
    2                    => "MQEVO_INIT - Initialization input data set",
    5                    => "MQEVO_INTERNAL - Directly by queue manager",
    4                    => "MQEVO_MQSET - MQSET call",
    3                    => "MQEVO_MSG - Message on SYSTEM.COMMAND.INPUT",
    0                    => "MQEVO_OTHER - Other",
   },

   ObjectType =>
   {
    7                    => "AuthInfo",
    10                   => "CFStruct",
    6                    => "Channel",
    2                    => "Namelist",
    3                    => "Process",
    1                    => "Queue",
    5                    => "QueueManager",
    4                    => "StorageClass",
   },

  );


1;
