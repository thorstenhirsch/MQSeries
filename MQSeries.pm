#
# $Id: MQSeries.pm,v 14.5 2000/08/15 20:51:25 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#
# This is intended to be a wrapper routine to include either the
# server or client library, based on the machine on which the code is
# running.
#

package MQSeries;

require 5.004;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

$VERSION = '1.11';

BEGIN {

    my $systemdir = q{/var/mqm/qmgrs/@SYSTEM};

    if ( $^O =~ /Win32/i ) {

	no strict;

	require "Win32/TieRegistry.pm";
	import Win32::TieRegistry;

	$Registry->Delimiter('/');

	my $CurrentVersion = "LMachine/SOFTWARE/IBM/MQSeries/CurrentVersion/";

	($systemdir) = (
			$Registry->{"$CurrentVersion/FilePath"} ||
			$Registry->{"$CurrentVersion/WorkPath"} ||
			"C:/Mqm"
		       ) . q{/qmgrs/@SYSTEM};

    }

    if (
	$INC{"MQServer/MQSeries.pm"} ||
	(  -d $systemdir && ! exists $INC{"MQClient/MQSeries.pm"} )
       ) {
	require "MQServer/MQSeries.pm";
	import MQServer::MQSeries;
	@EXPORT = @MQServer::MQSeries::EXPORT;
	$MQSeries::Mode = "Server";
    } else {
	require "MQClient/MQSeries.pm";
	import MQClient::MQSeries;
	@EXPORT = @MQClient::MQSeries::EXPORT;
	$MQSeries::Mode = "Client";
    }

}

1;

__END__

=head1 NAME

MQSeries - Perl extension for MQSeries support

=head1 SYNOPSIS

There are two interfaces provided by the MQSeries modules.  The first
is a straight forward mapping to all of the individual MQI calls, and
the second is a value-added, OO interface, which provides a simpler
interface to a subset of the full MQI functionality.

The straight MQI mapping is:

  use MQSeries;

  $Hconn = MQCONN($Name,$CompCode,$Reason);
  MQDISC($Hconn,$CompCode,$Reason);

  $Hobj = MQOPEN($Hconn,$ObjDesc,$Options,$CompCode,$Reason);
  MQCLOSE($Hconn,$Hobj,$Options,$CompCode,$Reason);

  MQBACK($Hconn,$CompCode,$Reason);
  MQCMIT($Hconn,$CompCode,$Reason);

  $Buffer = MQGET($Hconn,$Hobj,$MsgDesc,$GetMsgOpts,$BufferLength,$CompCode,$Reason);
  MQPUT($Hconn,$Hobj,$MsgDesc,%PutMsgOpts,$Msg,$CompCode,$Reason);
  MQPUT1($Hconn,$ObjDesc,$MsgDesc,$PutMsgOpts,$Msg,$CompCode,$Reason);

  ($Attr1,...) = MQINQ($Hconn,$Hobj,$CompCode,$Reason,$Selector1,...);
  MQSET($Hconn,$Hobj,$CompCode,$Reason,$Selector1,$Attr1,...);

If the perl5 API is compiled with the version 5 headers and libraries,
then the following MQI calls are also available:

  MQBEGIN($Hconn,$BeginOpts,$CompCode,$Reason);
  $Hconn = MQCONNX($Name,$ConnectOpts,$CompCode,$Reason);

There are also some additional utility routines provided which
are not part of the MQI, but specific to the perl5 API:

  ($ReasonText,$ReasonMacro) = MQReasonToStrings($Reason);
  ($ReasonText) = MQReasonToText($Reason);
  ($ReasonMacro) = MQReasonToMacro($Reason);

The OO interface is provided in several optional modules.  Three of
these make up the core OO interface:

  MQSeries::QueueManager
  MQSeries::Queue
  MQSeries::Message

There are several subclasses of MQSeries::Message which handle special
message formats:

  MQSeries::Message::Storable
  MQSeries::Message::Event
  MQSeries::Message::PCF
  MQSeries::Message::RulesFormat
  MQSeries::Message::XML-Dumper
  MQSeries::Message::DeadLetter

There is also a set of modules which provide an interface to the
optional Publish/Subscribe system, which is available as a support
pack for the distributed platforms using Version 5 of MQSeries.

  MQSeries::PubSub::Broker
  MQSeries::PubSub::Stream
  MQSeries::PubSub::Command (docs only, not used directly)
  MQSeries::PubSub::Message
  MQSeries::PubSub::AdminMessage

There is also a module which provides an interface to the command
server PCF messages for MQSeries administration:

  MQSeries::Command

There are two sets of classes that help you follow (tail -f style) and
parse the two kinds of log-files written by MQSeries: the FDC files
and the error-logs.  These classes allow you to write a log monitoring
daemon that feeds into syslog or your system management tools.

  MQSeries::ErrorLog::Tail
  MQSeries::ErrorLog::Parser
  MQSeries::ErrorLog::Entry
  MQSeries::FDC::Tail
  MQSeries::FDC::Parser
  MQSeries::FDC::Entry

There is a set of classes that parses configuration files (/var/mqm/mqs.ini
and /var/mqm/qmgrs/*/qm.ini):

  MQSeries::Config::Machine
  MQSeries::Config::QMgr

See the documentation for each of these individual modules for more
information.

=head1 DESCRIPTION

This module provides a perl language interface to MQSeries
functions. It uses the standard MQSeries interface except where a perl
convention is required or just more useful.

Where data structures are required, this interface uses a hash
reference. The keys in the hash are structure element names. If an
element is not specified in the hash, a default value will be
used. Output elements are updated in the hash as necessary.

=head1 SUBROUTINES

For complete details on each of the following subroutines, please
consult the "MQSeries Application Programming Guide" and "MQSeries
Application Programming Reference".  This documentation will merely
document how the perl API and the underlying C API calling and return
code conventions vary.

One way in which all of these calls are identical to the C API is in
the use of the '$CompCode' and '$Reason' conventions.  All of the API
calls take these as positional arguments, and the completion code and
reason code are written to those variables, respecitively.

In general, all of the C data structures used to pass or return values
to each API call are passed or returned as a perl hash reference,
specified as a positional argument in the relavent API call.

=head2 MQCONN

  $Hconn = MQCONN($Name,$CompCode,$Reason);

This call returns the Hconn value, to be used in subsequent MQI calls.
The C API took the $Hconn as a positional parameter, whereas the perl
API returns it.

=head2 MQCONNX

  $Hconn = MQCONNX($Name,$ConnectOpts,$CompCode,$Reason);

NOTE: This MQI call is only available if the perl5 API is compiled
against MQSeries version 5 headers and libraries.

This call returns the Hconn value, to be used in subsequent MQI calls.
The C API took the $Hconn as a positional parameter, whereas the perl
API returns it.

The $ConnectOpts value is a hash reference, with keys corresponding to
the fields of the MQCO structure.  This is an input value only.

=head2 MQDISC

  MQDISC($Hconn,$CompCode,$Reason);

The calling convention of this subroutine is identical to the C API.

=head2 MQOPEN

  $Hobj = MQOPEN($Hconn,$ObjDesc,$Options,$CompCode,$Reason);

In the same way that MQCONN loses one positional parameter, and
returns it to the caller, so does MQOPEN remove the $Hobj parameter
from the argument list and returns the value.

The $ObjDesc parameter should be a hash reference, for example:

  $ObjDesc = {
              ObjectName 	=> 'SOME.MODEL.QUEUE',
              DynamicQName 	=> 'FOOBAR*',
             };

The $Options parameter should be a set of ORed options, for example:

  $Options = MQOO_INPUT_AS_Q_DEF | MQOO_FAIL_IF_QUIESCING;

If a distribution list is being opened, then the list of queues can be
specified in one of three ways.  The list is given via a new key
"ObjectRecs", used to identify the list.  This is different from the
C-centric approach in the C API, namely to specify the list using the
RecsPresent, ObjectRecPtr, etc.

The first method is to specify an array of plain queue names:

  $ObjDesc = {
              ObjectRecs	=> [qw( QUEUE1 QUEUE2 QUEUE3 )],
             };

The second method is to specify an array or array references, each
giving the QName and QMgrName:

  $ObjDesc = {
              ObjectRecs	=> [
                                    [qw( QUEUE1 QM1 )],
                                    [qw( QUEUE2 QM2 )],
                                    [qw( QUEUE3 QM3 )],
                                   ],
             };

Finally, an array of hash references can be specified, each giving the
QName and QMgrName via specific keys:

  $ObjDesc = {
              ObjectRecs	=> [
                                    {
                                     ObjectName		=> 'QUEUE1',
                                     ObjectQMgrName	=> 'QM1',
                                    },
                                    {
                                     ObjectName		=> 'QUEUE2',
                                     ObjectQMgrName	=> 'QM2',
                                    },
                                    {
                                     ObjectName		=> 'QUEUE3',
                                     ObjectQMgrName	=> 'QM3',
                                    },
                                   ],
             };

In the second and third cases, the queue manager names are always
optional.  Which method to use is largely a matter of style.

When the Reason Code returned by the API is MQRC_MULTIPLE_REASONS,
then these are encoded into an array of hash references, and that
array is returned as a new key in the ObjDesc hash, "ResponseRecs".
The order of the CompCode/Reason pair in the array corresponds to the
order of the queues listed in the ObjectRecs array.

This is best explained in an example.  In this case, we used the
first, simple list of queue names for our distribution list.

  if ( $Reason == MQRC_MULTIPLE_REASONS ) {
      for ( $index = 0 ; $index <= scalar @{$ObjDesc->{ObjectRecs}} ; $index++ ) {
          next if $ObjDesc->{ResponseRecs}->[$index]->{Reason} == MQRC_NONE;
          print "QName: " . $ObjDesc->{ObjectRecs}->[$index] . "\n";
          print "Reason: " . $ObjDesc->{ResponseRecs}->[$index]->{Reason} . "\n";
          print "CompCode: " . $ObjDesc->{ResponseRecs}->[$index]->{CompCode} . "\n";
      }
  }

=head2 MQCLOSE

  MQCLOSE($Hconn,$Hobj,$Options,$CompCode,$Reason);

The calling convention of this subroutine is identical to the C API.

The $Options value is a set of ORed options, for example:

  $Options = MQCO_DELETE_PURGE;

=head2 MQBEGIN

  MQBEGIN($Hconn,$BeginOpts,$CompCode,$Reason)

NOTE: This MQI call is only available if the perl5 API is compiled
against MQSeries version 5 headers and libraries.

The calling convention of this subroutine is identical to the C API.

The $BeginOpts value is a hash reference, with keys corresponding to
the fields of the MQBO structure.  This is both an input and output value.

=head2 MQBACK

  MQBACK($Hconn,$CompCode,$Reason);

The calling convention of this subroutine is identical to the C API.

=head2 MQCMIT

  MQCMIT($Hconn,$CompCode,$Reason);

The calling convention of this subroutine is identical to the C API.

=head2 MQGET

  $Buffer = MQGET($Hconn,$Hobj,$MsgDesc,$GetMsgOpts,$BufferLength,$CompCode,$Reason);

One positional parameter, the $Buffer, is removed from the argument
list.  This is the return value of this subroutine.  The $MsgDesc and
$GetMsgOpts values are hash references.  The $MsgDesc will be
populated with the MQMD structure returned by the MQGET call.  This is
also an input value, and the $MsgDesc data can be populated, for
example, with a specific 'CorrelId'.

  $MsgDesc = {
              CorrelId => $correlid,
             };

The $GetMsgOpts hash reference contains the MQGMO data structure
fields, for example:

  $GetMsgOpts = {
                 Options => MQGMO_FAIL_IF_QUIESCING | MQGMO_SYNCPOINT | MQGMO_WAIT,
                 WaitInterval => MQWI_UNLIMITED,
                };

=head2 MQPUT, MQPUT1

  MQPUT($Hconn,$Hobj,$MsgDesc,$PutMsgOpts,$Msg,$CompCode,$Reason);
  MQPUT1($Hconn,$ObjDesc,$MsgDesc,$PutMsgOpts,$Msg,$CompCode,$Reason);

Both of these calls differ from the C API in the same way as MQGET.
Likewise, the $MsgDesc and $PutMsgOpts values are hash references for
the appropriate data structures.

If MQPUT1() is being used to put a message to a distribution list,
then the $ObjDesc is used in the same way as documented above for
MQOPEN().  In addition, there is a special key to the $PutMsgOpts hash
which can be specified, and the rest of this discussion applies
equally to both MQPUT() and MQPUT1().

The $PutMsgOpts->{PutMsgRecs} value must be an array of hash
references, one for each queue opened in the distribution list,
interpreted in the same order.  Each individual hash reference is
interpreted as a single put message record.  The keys of each record
can be any of:

  MsgId
  CorrelId
  GroupId
  Feedback
  AccountingToken

For example, the following sets the CorrelId the same across all of
the messages in a distribution list of three queues.

  $PutMsgOpts = {
                 PutMsgRecs => [
                                {
                                 MsgId		=> MQPMO_NEW_MSG_ID,
                                 CorrelId       => $SomeCorrelId,
                                },
                                {
                                 MsgId		=> MQPMO_NEW_MSG_ID,
                                 CorrelId       => $SomeCorrelId,
                                },
                                {
                                 MsgId		=> MQPMO_NEW_MSG_ID,
                                 CorrelId       => $SomeCorrelId,
                                },
                               ],
                };

Note that the following fields of the $PutMsgOpts hash do not need to
be specified:

  PutMsgRecFields (calculated automatically)
  PutMsgRecOffset
  PutMsgRecPtr
  ResponseRecPtr
  ResponseRecOffset

For the MQPUT() call, if the Reason code returned is
MQRC_MULTIPLE_REASONS, then these are returned as part of the
$PutMsgOpts hash, in the key ResponseRecs.  For the MQPUT1() call,
these are returned as part of the $ObjDesc hash.

See the MQOPEN() documentation above for the format of this value.

=head2 MQINQ

  ($Attr1,...) = MQINQ($Hconn,$Hobj,$CompCode,$Reason,$Selector1,...);

This call differs from the C API significantly.  Rather than passing a
list of pairs of selectors and attributes, only a list of selectors is
passed.  The return value is a list of attributed.  The C API
convention was simply to pass the address for each answer in the
arguments, but in perl, it makes more sense to return this as a list.

=head2 MQSET

  MQSET($Hconn,$Hobj,$CompCode,$Reason,$Selector1,$Attr1,...);

This call also differs from the C API significantly.  The C API took a
pointer to an array of selectors, with an argument indicating the
length of the array, and a similar pair of values for the attribute
values themselves.  The perl convention is to list the selectors and
attributes in pairs, rather than by passing in an array reference.

=head2 MQParseEvent (deprecated in 1.06)

This routine has been deprecated, and is no longer supported.  The
next release will remove it from the documentation altogether.  

Equivalent functionality is available via the MQDecodePCF subroutine,
which is optionally exported from the MQSeries::Message::PCF module.  

The author highly recommends using the OO abstraction via
MQSeries::Message::Event, and interface which is supported and will
remain part of this API permanently.

=head2 MQReasonToStrings

  ($ReasonText,$ReasonMacro) = MQReasonToStrings($Reason);

This subroutine is specific to the perl API, although similar
functionality is desperately needed in the other programming languages
as well.  This takes an MQSeries Reason code, and returns the English
language text explaining the reason code, and the macro name.  These
strings are compiled into the perl module, encoded in the XS routines,
after having been extracted from the IBM HTML documentation.

For example, a reason code of 2009 (MQRC_CONNECTION_BROKEN) will return:

  "Connection to queue manager lost."

which looks a lot better in error logs and alerts than 2009.

The macro name itself is also returned as a string, so one could use
"MQRC_CONNECTION_BROKEN" is logs, error messages, etc.

In this release (1.06) only English language text is returned, but in
a future release, these messages will be locale specific.  This will
almost certainly be implemented with locale-specific DBM files, but
you probably do not need to know this just yet....

=head2 MQReasonToText

  ($ReasonText) = MQReasonToText($Reason);

This is nothing more than a trivial interface to MQReasonToStrings,
returning just the one value (the reason text).  

=head2 MQReasonToMacro

  ($ReasonMacro) = MQReasonToMacro($Reason);

This is nothing more than a trivial interface to MQReasonToStrings,
returning just the one value (the MQRC_* macro as a string).  

=cut
