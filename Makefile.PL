#
# (c) 1999 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#
# $Id: Makefile.PL,v 11.1 1999/11/24 12:52:33 wpm Exp $
#
use ExtUtils::MakeMaker;

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
# Create the MQServer directory and symlinks on the fly...
#
unless ( -d "MQServer" ) {
    warn "Creating directory MQServer.\n";
    unless ( mkdir("MQServer",0755) ) {
	die "Unable to mkdir MQServer: $!\n";
    }
}

my @files = qw(
	       MQSeries.pm.in
	       MQSeries.xs.in
	       Makefile.PL
	       constants.c.PL
	       typemap.PL
	      );

foreach my $file ( @files ) {

    my $dest = "../MQClient/$file";
    my $src = "MQServer/$file";
    
    if ( -l $src ) {
	my $readlink = readlink($src) || 
	  die "Unable to readlink $src: $!\n";
	unless ( $readlink eq $dest ) {
	    warn "Removing incorrect symlink $src -> $readlink\n";
	    unlink($src) || die "Unable to unlink $src: $!\n";
	}
    }

    unless ( -l $src ) {
	warn "Creating symlink $src -> $dest\n";
	symlink($dest,$src) || die "Unable to symlink $src -> $dest: $!\n";
    }
    
}

closedir(MQCLIENT);

WriteMakefile(
	      NAME	   	=> 'MQSeries',
	      VERSION_FROM 	=> 'MQSeries.pm', # finds $VERSION
	     );

