#
# WARNING: This file is automatically generated.
# Any changes made here will be mercilessly lost.
#
# You have been warned, infidel.
#
# P.S. For the real source to this file, see:
#
#    ..../src/pre.in/MQSeries/Command/PCF/Requests.in
#
# and for the evil hackery used to generate this, see:
#
#    ..../src/util/flatten_macros
#
# (c) 1999-2002 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#
package MQSeries::Command::PCF;

%Requests =
  (
   ChangeAuthInfo               => [ 79,                                 $RequestParameters{AuthInfo} ],
   ChangeChannel                => [ 21,                                 $RequestParameters{Channel} ],
   ChangeNamelist               => [ 32,                                 $RequestParameters{Namelist} ],
   ChangeProcess                => [ 3,                                  $RequestParameters{Process} ],
   ChangeQueue                  => [ 8,                                  $RequestParameters{Queue} ],
   ChangeQueueManager           => [ 1,                                  $RequestParameters{QueueManager} ],
   ClearQueue                   => [ 9,                                  $RequestParameters{Queue} ],
   CopyAuthInfo                 => [ 80,                                 $RequestParameters{AuthInfo} ],
   CopyChannel                  => [ 22,                                 $RequestParameters{Channel} ],
   CopyNamelist                 => [ 33,                                 $RequestParameters{Namelist} ],
   CopyProcess                  => [ 4,                                  $RequestParameters{Process} ],
   CopyQueue                    => [ 10,                                 $RequestParameters{Queue} ],
   CreateAuthInfo               => [ 81,                                 $RequestParameters{AuthInfo} ],
   CreateChannel                => [ 23,                                 $RequestParameters{Channel} ],
   CreateNamelist               => [ 34,                                 $RequestParameters{Namelist} ],
   CreateProcess                => [ 5,                                  $RequestParameters{Process} ],
   CreateQueue                  => [ 11,                                 $RequestParameters{Queue} ],
   DeleteChannel                => [ 24,                                 $RequestParameters{Channel} ],
   DeleteNamelist               => [ 35,                                 $RequestParameters{Namelist} ],
   DeleteProcess                => [ 6,                                  $RequestParameters{Process} ],
   DeleteQueue                  => [ 12,                                 $RequestParameters{Queue} ],
   Escape                       => [ 38,                                 $RequestParameters{Escape} ],
   InquireAuthInfo              => [ 83,                                 $RequestParameters{AuthInfo} ],
   InquireAuthInfoNames         => [ 84,                                 $RequestParameters{AuthInfo} ],
   InquireChannel               => [ 25,                                 $RequestParameters{Channel} ],
   InquireChannelNames          => [ 20,                                 $RequestParameters{Channel} ],
   InquireChannelStatus         => [ 42,                                 $RequestParameters{Channel} ],
   InquireClusterQueueManager   => [ 70,                                 $RequestParameters{Cluster} ],
   InquireNamelist              => [ 36,                                 $RequestParameters{Namelist} ],
   InquireNamelistNames         => [ 37,                                 $RequestParameters{Namelist} ],
   InquireProcess               => [ 7,                                  $RequestParameters{Process} ],
   InquireProcessNames          => [ 19,                                 $RequestParameters{Process} ],
   InquireQueue                 => [ 13,                                 $RequestParameters{Queue} ],
   InquireQueueManager          => [ 2,                                  $RequestParameters{QueueManager} ],
   InquireQueueNames            => [ 18,                                 $RequestParameters{Queue} ],
   InquireQueueStatus           => [ 41,                                 $RequestParameters{QueueStatus} ],
   PingChannel                  => [ 26,                                 $RequestParameters{Channel} ],
   PingQueueManager             => [ 40,                                 $RequestParameters{QueueManager} ],
   RefreshCluster               => [ 73,                                 $RequestParameters{Cluster} ],
   ResetChannel                 => [ 27,                                 $RequestParameters{Channel} ],
   ResetCluster                 => [ 74,                                 $RequestParameters{Cluster} ],
   ResetQueueStatistics         => [ 17,                                 $RequestParameters{Queue} ],
   ResolveChannel               => [ 39,                                 $RequestParameters{Channel} ],
   ResumeQueueManagerCluster    => [ 71,                                 $RequestParameters{Cluster} ],
   StartChannel                 => [ 28,                                 $RequestParameters{Channel} ],
   StartChannelInitiator        => [ 30,                                 $RequestParameters{Channel} ],
   StartChannelListener         => [ 31,                                 $RequestParameters{Channel} ],
   StopChannel                  => [ 29,                                 $RequestParameters{Channel} ],
   SuspendQueueManagerCluster   => [ 72,                                 $RequestParameters{Cluster} ],

   #
   # Extended command set
   #
   InquireAuthority             => [ 1000,                               $RequestParameters{Authority} ],
   ChangeAuthority              => [ 1001,                               $RequestParameters{Authority} ],

  );


1;
