#
# WARNING: This file is automatically generated.
# Any changes made here will be mercilessly lost.
#
# You have been warned, infidel.
#
# P.S. For the real source to this file, see:
#
#    ..../src/pre.in/MQSeries/Command/PCF/RequestParameterOrder.in
#
# and for the evil hackery used to generate this, see:
#
#    ..../src/util/flatten_macros
#
# (c) 1999-2003 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#
package MQSeries::Command::PCF;

#
# Some of the PCF commands have order dependencies for the optional
# parameters.  MQSeries::Command is smart enough to put required in
# front of optional, but this configuration will guarantee the order
# of the optional parameters, where necessary.
#

%RequestParameterOrder =
  (
   DeleteQueue			=> [ qw(QType Purge) ],

   InquireQueueStatus           => [ qw(StatusType OpenType QStatusAttrs) ],
   InquireClusterQueueManager   => [ qw(Channel ClusterName ClusterQMgrAtrrs) ],
  );

1;
