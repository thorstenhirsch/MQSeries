#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#
# $Id: Makefile.PL,v 12.4 2000/03/03 18:41:34 wpm Exp $
#
use English;
use ExtUtils::MakeMaker;
use File::Copy;

#
# I hate these file turds, but I only want you to have to answer this
# obnoxious question once.
#
unless ( -f ".LICENSE.ACCEPTED" ) {

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
    my $answer = <STDIN>;
    exit 1 if $answer =~ /^n/i;

    open(YES,">.LICENSE.ACCEPTED") ||
      die "Unable to write .LICENSE.ACCEPTED: $!\n";
    close(YES) ||
      die "Unable to close .LICENSE.ACCEPTED: $!\n";

    print "\n";

}

#
# Create the MQServer directory and files on the fly.
#
# This used to be a bunch of symlinks, but Win32 makes this
# impractical.  This is already gross enough, so I'm just going to
# copy everything over, and keep it uptodate.  If any of the MQClient
# files changes, then you'll need to re-run the Makefile.PL.
#
# Hmm...  Maybe I can make a bunch of special makefile targets to
# force the update.  Hmm....
#
my %files =
  (
   "MQServer/"				=> 1,
   "MQServer/MQSeries.xs.in/"		=> 1,
   "MQServer/Makefile.PL"		=> "MQClient/Makefile.PL",
   "MQServer/constants.c.PL"		=> "MQClient/constants.c.PL",
   "MQServer/typemap.PL"		=> "MQClient/typemap.PL",
   "MQServer/MQSeries.pm.in"		=> "MQClient/MQSeries.pm.in",
  );

opendir(MQCLIENT,"MQClient/MQSeries.xs.in") ||
  die "Unable to opendir MQClient/MQSeries.xs.in: $ERRNO\n";

foreach ( readdir(MQCLIENT) ) {
    next if /^\.\.?$/;
    next if $_ eq 'RCS';
    next if $_ =~ /~$/;
    $files{"MQServer/MQSeries.xs.in/$_"} = "MQClient/MQSeries.xs.in/$_";
}

closedir(MQCLIENT);

foreach my $dest ( sort keys %files ) {

    if ( $dest =~ m:/$: ) {

	next if -d $dest;
	warn "Creating directory $dest\n";
	mkdir($dest,0755) || die "Unable to mkdir $dest:\n";

    } else {

	my $src = $files{$dest};

	if ( -f $dest ) {
	    my (@src)  = stat($src)  or die "Unable to stat $src: $ERRNO\n";
	    my (@dest) = stat($dest) or die "Unable to stat $dest: $ERRNO\n";
	    next if $dest[9] >= $src[9];
	}

	warn "Copying $src -> $dest\n";

	copy($src,$dest) || die "Unable to copy $src to $dest: $ERRNO\n";
	
    }

}

WriteMakefile(
	      NAME	   	=> 'MQSeries',
	      VERSION_FROM 	=> 'MQSeries.pm', # finds $VERSION
	      (
	       $] ge '5.005' ?
	       (
		AUTHOR		=> 'W. Phillip Moore (Phil.Moore@msdw.com)',
		ABSTRACT	=> "Interface to IBM's MQSeries Product",
	       ) : ()
	      )
	     );


