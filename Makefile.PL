#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#
# $Id: Makefile.PL,v 9.1 1999/10/14 23:01:33 wpm Exp $
#
use ExtUtils::MakeMaker;

print <<"LegalMumboJumbo";

[[ My lawyers made me do this.  Flames to /dev/null.  -- wpm ]]

This software is is licensed as open source code and is subject to the
terms and conditions of a license agreement that is set forth in the
included LICENSE file.  

If you have read the license agreement and accept its terms and
conditions, answer "yes" to continue with the installation.  If you
have not read the license agreement or do not accept its terms and
conditions, answer "no" and fire up your favorite text editor....

LegalMumboJumbo

print "Did you read the LICENSE file and agree to its terms and conditions? [y] ";
my $answer = <>;
exit 1 if $answer =~ /^n/i;

print "\n";

WriteMakefile(
	      NAME	   	=> 'MQSeries',
	      VERSION_FROM 	=> 'MQSeries.pm', # finds $VERSION
	     );

