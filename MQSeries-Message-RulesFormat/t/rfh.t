#
# $Id: rfh.t,v 16.1 2001/01/05 21:43:19 wpm Exp $
#
# (c) 1999-2001 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

#
# The 13 has to be updated experimentally if the tests are extended.
#
BEGIN {
    print "1..13\n";
}

#
# We need this to pick up the PERL_DL_NONLAZY definition,
# conditionally.
#
BEGIN {
    require "../util/parse_config";
}

END { print "not ok 1\n" unless $loaded; }
use MQSeries;
use MQSeries::Message::RulesFormat qw( MQDecodeRulesFormat MQEncodeRulesFormat );
$loaded = 1;
print "ok 1\n";

$msgin = MQSeries::Message::RulesFormat->new
  (
   Header		=>
   {
    Format		=> MQFMT_STRING,
   },
   Options		=> 
   {
    Key1		=> 'Some string with "Embedded" double quotes',
    Key2		=> 
    [
     "A bunch",
     'of "strings"',
     "that are not really interesting",
    ],
    Key3		=> "one more",
   },
   Data			=> "Like this is less boring...\n",
  );

unless ( ref $msgin && $msgin->isa("MQSeries::Message::RulesFormat") ) {
    print "MQSeries::Message::RulesFormat constructor failed\n";
    print "not ok 2\n";
    exit 0;
}

print "ok 2\n";

$msgout = MQSeries::Message::RulesFormat->new();

unless ( ref $msgout && $msgout->isa("MQSeries::Message::RulesFormat") ) {
    print "MQSeries::Message::RulesFormat constructor failed\n";
    print "not ok 3\n";
    exit 0;
}

print "ok 3\n";

#
# Now we simulate the put/get of this message.  Do not try this at
# home.  We are trained professionals.
#
$bufferin = $msgin->PutConvert($msgin->Data());

unless ( defined $bufferin ) {
    print "Unable to PutConvert input message\n";
    print "not ok 4\n";
    exit 0;
}

print "ok 4\n";

$dataout = $msgout->GetConvert($bufferin);

unless ( defined $dataout ) {
    print "Unable to GetConvert output message\n";
    print "not ok 5\n";
    exit 0;
}

print "ok 5\n";

#
# OK, things aren't totally hopeless.  Let's see if the data came out
# right.
#
unless ( $msgin->Header("Format") eq $msgin->Header("Format") ) {
    print("Header->Format value is different\n" .
	  "Input value  => '" . $msgin->Header("Format") . "'\n" .
	  "Output value => '" . $msgout->Header("Format") . "'\n");
    print "not ";
}

print "ok 6\n";

$optionsin = $msgin->Options();
unless ( ref $optionsin eq "HASH" ) {
    print("Input Options method did not return a HASH reference\n");
    print "not ok 7\n";
    exit 0;
}
print "ok 7\n";

$optionsout = $msgout->Options();
unless ( ref $optionsin eq "HASH" ) {
    print("Output Options method did not return a HASH reference\n");
    print "not ok 8\n";
    exit 0;
}
print "ok 8\n";

$curtest = 9;

foreach my $key ( keys %$optionsin ) {
    
    if ( ref $optionsin->{$key} eq "ARRAY" ) {
	
	unless ( ref $optionsout->{$key} eq "ARRAY" ) {
	    print("Options->$key is not an ARRAY reference\n");
	    for ( my $index = 0 ; $index < scalar(@{$optionsin->{$key}}) ; $index++ ) {
		print "not ok $curtest\n";
		$curtest++;
	    }
	    next;
	}

	for ( my $index = 0 ; $index < scalar(@{$optionsin->{$key}}) ; $index++ ) {

	    unless ( $optionsin->{$key}->[$index] eq $optionsout->{$key}->[$index] ) {
		print("Options->$key->[$index] value is different:\n" .
		      "Input value  => '$optionsin->{$key}->[$index]'\n" .
		      "Output value => '$optionsout->{$key}->[$index]'\n");
		print "not ";
	    }
	    print "ok $curtest\n";
	    $curtest++;
	}

    }
    else {

	unless ( $optionsin->{$key} eq $optionsout->{$key} ) {
	    print("Options->$key value is different:\n" .
		  "Input value  => '$optionsin->{$key}'\n" .
		  "Output value => '$optionsout->{$key}'\n");
	    print "not ";
	}
	print "ok $curtest\n";
	$curtest++;

    }

}
