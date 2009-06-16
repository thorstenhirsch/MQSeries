#
# $Id: 30basic.t,v 32.1 2009/05/22 15:28:16 biersma Exp $
#
# (c) 1999-2007 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

BEGIN {
    require "../util/parse_config";
}

BEGIN { 
    $| = 1;
    if ( "__APITYPE__" eq "MQServer" && ! -d $systemdir ) {
	print "1..0\n";
	exit 0;
    } else {
	print "1..17\n";
    }
}

END {print "not ok 1\n" unless $loaded;}
use __APITYPE__::MQSeries 1.29;
$loaded = 1;
print "ok 1\n";

$QMgrName 	= $myconfig{"QUEUEMGR"};
$QName 		= $myconfig{"QUEUE"};

$CompCode 	= 0;
$Reason 	= 0;
$Hconn 		= 0;

print "Connecting to queue manager '$QMgrName' (MQCONN)\n";
$Hconn = MQCONN($QMgrName,$CompCode,$Reason);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print "MQCONN failed: CompCode => $CompCode, Reason => $Reason\n";
    print "not ok 2\n";
    exit 0;
} else {
    print "ok 2\n";
}

$Options = MQOO_INQUIRE | MQOO_OUTPUT | MQOO_INPUT_AS_Q_DEF | MQOO_SET;
$ObjDesc = {
	    ObjectType 		=> MQOT_Q,
	    ObjectName 		=> $QName,
	    ObjectQMgrName 	=> ""
	   };
$Hobj = 0;

print "Opening queue '$QName' (MQOPEN)\n";
$Hobj = MQOPEN($Hconn,$ObjDesc,$Options,$CompCode,$Reason);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQOPEN failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 3\n");
    $Hobj = -1;
} else {
    print "ok 3\n";
}


print "Querying several queue attributes (MQINQ)\n";
($MaxMsgLength, $QueueName, $CreationDate, $CreationTime, $MaxQDepth) =
	(-1, -1, -1, -1, -1);	# defeats -w
($MaxMsgLength, $QueueName, $CreationDate, $CreationTime, $MaxQDepth) =
  MQINQ($Hconn,$Hobj,$CompCode,$Reason,
	MQIA_MAX_MSG_LENGTH,
	MQCA_Q_NAME,
	MQCA_CREATION_DATE,
	MQCA_CREATION_TIME,
	MQIA_MAX_Q_DEPTH);


print("MQINQ returned: CompCode => $CompCode, Reason => $Reason\n");

if ( $CompCode != MQCC_OK
     || $Reason != MQRC_NONE ) {
    print("MQINQ failed: CompCode => $CompCode, Reason => $Reason\n"
	  #	  , "MaxMsgLength => $MaxMsgLength\n"
	  #	  , "QueueName => $QueueName\n"
	  #	  , "CreationDate => $CreationDate\n"
	  #	  , "CreationTime => $CreationTime\n"
	  #	  , "MaxQDepth => $MaxQDepth\n"
	  , "not ok 4\n"
	 );
} else {
    print "ok 4\n";
}

print "Putting message (MQPUT)\n";
$tempMsg = "Now is the time for all good men to come to the aid of their country.";
$MsgDesc = {};			# gets rid of -w warning
$PutMsgOpts = {};
MQPUT($Hconn,$Hobj,$MsgDesc,$PutMsgOpts,$tempMsg,$CompCode,$Reason);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQPUT failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 5\n");
} else {
    print "ok 5\n";
}

print "Getting message using buffer size 10, failure expected (MQGET)\n";
$MsgDesc = {};
$GetMsgOpts = {};
$tempLen = 10;
$tempMsg = MQGET($Hconn,$Hobj,$MsgDesc,$GetMsgOpts,$tempLen,$CompCode,$Reason);
if ( $Reason != MQRC_TRUNCATED_MSG_FAILED || $tempMsg ne "Now is the" ) {
    print("MQGET should have failed, due to truncation\n" .
	  "CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 6\n");
} else {
    print "ok 6\n";
}

print "Getting message using buffer size 80 (MQGET)\n";
$MsgDesc = {};
$GetMsgOpts = {};
$tempLen = 80;
$tempMsg = MQGET($Hconn,$Hobj,$MsgDesc,$GetMsgOpts,$tempLen,$CompCode,$Reason);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQGET failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 7\n");
} else {
    print "ok 7\n";
}

print "Inhibiting Get and setting Trigger Data (MQSET)\n";
MQSET($Hconn,$Hobj,$CompCode,$Reason,MQIA_INHIBIT_GET,MQQA_GET_INHIBITED,MQCA_TRIGGER_DATA,"bogusdata");
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQSET failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 8\n");
} else {
    print "ok 8\n";
}

print "Inquiring Inhibit Get and Trigger Data (MQINQ)\n";
($inhibitGet,$trigData) = ("", "");	# defeats -w
($inhibitGet,$trigData) = MQINQ($Hconn,$Hobj,$CompCode,$Reason,MQIA_INHIBIT_GET,MQCA_TRIGGER_DATA);
#$trigData =~  s/\s*(.*?)\s*$/$1/;
if (
    $CompCode != MQCC_OK ||
    $Reason != MQRC_NONE ||
    $trigData !~ /^bogusdata\s*/
   ) {
    print("MQINQ failed: CompCode => $CompCode, Reason => $Reason\n" .
	  #	  "Trigger data should be 'bogusdata', is '$trigData'\n" .
	  "not ok 9\n");
} else {
    print "ok 9\n";
}

print "Uninhibiting Get and clearing Trigger Data (MQSET)\n";
MQSET($Hconn,$Hobj,$CompCode,$Reason,MQIA_INHIBIT_GET,MQQA_GET_ALLOWED,MQCA_TRIGGER_DATA,"");
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQSET failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 10\n");
} else {
    print "ok 10\n";
}

print "Inquiring Inhibit Get and Trigger Data (MQINQ)\n";
($inhibitGet,$trigData) = MQINQ($Hconn,$Hobj,$CompCode,$Reason,MQIA_INHIBIT_GET,MQCA_TRIGGER_DATA);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQINQ failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 11\n");
} else {
    print "ok 11\n";
}

print "Closing queue (MQCLOSE)\n";
MQCLOSE($Hconn,$Hobj,MQCO_NONE,$CompCode,$Reason);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQCLOSE failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 12\n");
} else {
    print "ok 12\n";
}

print "Putting message to queue (MQPUT1)\n";
$ObjDesc = {
	    ObjectType 		=> MQOT_Q,
	    ObjectName 		=> $QName,
	    ObjectQMgrName 	=> "",
	   };
$MsgDesc = {};
$PutMsgOpts = {};
$tempMsg = "This msg was put with PERLMQ's MQPUT1 function.";
MQPUT1($Hconn,$ObjDesc,$MsgDesc,$PutMsgOpts,$tempMsg,$CompCode,$Reason);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQPUT1 failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 13\n");
} else {
    print "ok 13\n";
}


print "Opening queue (MQOPEN)\n";
$ObjDesc = {
	    ObjectType => MQOT_Q,
	    ObjectName => $QName,
	    ObjectQMgrName => ""
	   };
$Hobj = MQOPEN($Hconn,$ObjDesc,MQOO_INPUT_AS_Q_DEF,$CompCode,$Reason);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQOPEN failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 14\n");
} else {
    print "ok 14\n";
}

print "Getting message (MQGET)\n";
$MsgDesc = {};
$GetMsgOpts = {};
$tempLen = 80;
$tempMsg = MQGET($Hconn,$Hobj,$MsgDesc,$GetMsgOpts,$tempLen,$CompCode,$Reason);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQGET failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 15\n");
} else {
    print "ok 15\n";
}

print "Closing queue (MQCLOSE)\n";
MQCLOSE($Hconn,$Hobj,MQCO_NONE,$CompCode,$Reason);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQCLOSE failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 16\n");
} else {
    print "ok 16\n";
}

print "Disconnecting (MQDISC)\n";
MQDISC($Hconn,$CompCode,$Reason);
if ( $CompCode != MQCC_OK || $Reason != MQRC_NONE ) {
    print("MQDISC failed: CompCode => $CompCode, Reason => $Reason\n" .
	  "not ok 17\n");
} else {
    print "ok 17\n";
}


