#
# $Id: Makefile.PL,v 15.3 2000/10/24 01:05:15 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

use ExtUtils::MakeMaker;
use Config;
use English;
use Cwd;
use File::Basename;

require "../util/parse_config";
require "../util/parse_headers";
require "../util/fake_mm";

#
# Are we building the client, or server?
#
if ( cwd =~ m:/MQClient/?: ) {
    $apitype = "MQClient";
}
else {
    $apitype = "MQServer";
    # Override this for the server test (use the default queuemgr)
    $myconfig{QUEUEMGR} = "" if $myconfig{USE_DEFAULT_QMGR};
}

#
# Here's the logic for determining whether or not we can support the
# server API or not.  These %myconfig entries may be overridden in the
# CONFIG file.
#
if ( $Config{osname} =~ /(irix|sunos)/ ) {
    # NOTE: On IRIX and SunOS 4.x, we can *only* build the client.
    warn("No support for MQServer compiles on platform '$Config{osname}'\n") 
      if $apitype eq 'MQServer'; # Whine once...
    $myconfig{NOSERVER}++;
}

#
# Probably a reasonable default....
#
# XXX -- what other library names are valid?
# Note that on OS/390 perl's -f stat() tests do not work with PDSes.
#
unless (
	-f "$mqmtop/lib/libmqm.so" ||
	-f "$mqmtop/lib/libmqm.sl" ||
	-f "$mqmtop/lib/libmqm.a" ||
	-f "$mqmtop/lib/mqm.lib" ||
	$^O eq "os390"
       ) {
    warn("No libmqm server library found, MQServer disabled\n")
      if $apitype eq 'MQServer'; # Whine once...
    $myconfig{NOSERVER}++;
}

#
# This is bad -- if you don't have either one, there's no point in
# building this code.
#
if ( $myconfig{NOCLIENT} && $myconfig{NOSERVER} ) {
    die "Both the MQClient and MQServer API's have been disabled!!\n";
}

if (
    ( $apitype eq "MQClient" && $myconfig{NOCLIENT} )
    ||
    ( $apitype eq "MQServer" && $myconfig{NOSERVER} )
   ) {
    warn("Support for $apitype is disabled on this platform.\n");
    myWriteEmptyMakefile();
    return;
}

#
# Now we have to specify the list of libraries needed on each platform
#

#
# XXX -- this hack handles the white space in pathnames prevalent on
# Win32.  At least on Solaris, quoting the -L path doesn't work.
#
if ( $mqmtop =~ /\s/ ) {
    $libdir = "-L'$mqmtop/lib'";
}
else {
    $libdir = "-L$mqmtop/lib";
}

if ( $Config{osname} =~ /os390/ ) {
    $libs = "-l\"//'$hlq.SCSQLOAD'\"";
} else {
    if ( $apitype eq "MQClient" ) {
	$libs = "$libdir -lmqicg -lmqic -lmqic32 -lmqmcs -lmqmzse";
    } else {
	$libs = "$libdir -lmqm -lmqmcs -lmqmzse";
    }
}

#
# There may very well be other platforms on which we need -lthread.
#
if ( $Config{osname} =~ /solaris/ ) {
    $libs .= " -lthread";
}

#
# Autoconstruct the test files, MQSeries.pm and MQSeries.xs
#
unless ( -d "t" ) {
    mkdir("t",0755) || die "Unable to mkdir t: $ERRNO\n";
}

%filemap = (
	    "MQSeries.xs.in"		=> "MQSeries.xs",
	    "MQSeries.pm.in" 		=> "MQSeries.pm",
	   );

opendir(TEST,"../t.in") || die "Unable to opendir ../t.in: $ERRNO\n";

foreach $file ( readdir(TEST) ) {
    next unless $file =~ /\.t$/;
    $filemap{"../t.in/$file"} = "t/$file";
}

closedir(TEST);

foreach $file ( sort keys %filemap ) {

    my @files = ();

    if ( -d $file ) {
	opendir(INDIR,$file) || die "Unable to opendir $file: $ERRNO\n";
	foreach ( readdir(INDIR) ) {
	    next if /^\.\.?$/;
	    next unless /^\d{2}/;
	    next if /~$/;	# skip emacs backup files
	    #
	    # Skip files that do not match the current major version.
	    # This lets us include MQCONNX and MQBEGIN only if we are
	    # V5.
	    #
	    if ( /-v(\d+)$/ ) {
		next unless $mqversion == $1;
	    }
	    push(@files,"$file/$_");
	}
	closedir(INDIR);
    } else {

        @files = ($file);
    }

    open(OUT,">$filemap{$file}") || 
      die "Unable to write to $filemap{$file}: $ERRNO\n";

    foreach my $subfile ( sort @files ) {

	open(IN,$subfile) || die "Unable to open $subfile: $ERRNO\n";

	while ( <IN> ) {
	
	    #
	    # Special case: include the header files in the right order,
	    # based on what's available.
	    #
	    if ( /__INCLUDES__/ ) {

		foreach my $header ( grep(/cmqc\.h$/,@headers),
				     grep(!/cmqc\.h$/,@headers) ) {
		    my $filename = basename($header);
		    print OUT "#include <$filename>\n";
		}

		next;

	    }
	
	    #
	    # Another special case: include the macros found in the header
	    # files dynamically.
	    #
	    if ( /__CONSTANTS__/ ) {

		foreach my $constant (
				      sort (
					    keys %constant_hex,
					    keys %constant_numeric,
					    keys %constant_string,
					    keys %constant_null,
					    keys %constant_char
					   )
				     ) {
		    #
		    # NOTE: 13 is the indentation of the qw() construct
		    # being assigned to @EXPORT in MQSeries.pm.in.  This
		    # is the author being incredibly anal about the
		    # style....
		    #
		    print OUT " " x 13 . "$constant\n";
		}

		next;

	    }
	
	    if ( /__CONSTANT_NULL__/ ) {

		foreach my $constant ( sort keys %constant_null ) {
		    # More anal retentive indentation (the 3 and 20, that is)
		    print OUT (" " x 3 . $constant .
			       " " x (20 - length($constant)) .
			       "=> $constant_null{$constant},\n");
		}

		next;

	    }
	
	    s/__APITYPE__/$apitype/g;
	    s/__LOCALE__/$mqmlocale/g;
	    s/__TEST_QUEUE__/$myconfig{QUEUE}/g;
	    s/__TEST_QUEUE_MANAGER__/$myconfig{QUEUEMGR}/g;
	    print OUT $_;
	
	}

	close(IN) || die "Unable to close $subfile: $ERRNO\n";

    }

    close(OUT) || die "Unable to close $filemap{$file}: $ERRNO\n";

}

#
# Cheap hack to convince WriteMakefile that we have a local typemap,
# even though it will be generated by typemap.PL.  W/o this hack,
# xsubpp is not called with a -typemap ./typemap argument.
#
open(TYPEMAP, ">>typemap") || die "Unable to touch typemap: $ERRNO\n";
close(TYPEMAP);

WriteMakefile(
	      NAME		=> "${apitype}::MQSeries",
	      VERSION_FROM	=> "MQSeries.pm",
	      LIBS		=> [$libs],
	      INC		=> qq{-I"$include" -I../include},
	      EXE_FILES		=> [],
	      OBJECT		=> q[MQSeries$(OBJ_EXT) constants$(OBJ_EXT)],
	      (
	       $^O eq 'os390' ?
	       (
		MAN3PODS	=> {},
	       ) : ()
	      ),
              #
	      # On Win32, we need to force the use of the CAPI
              # with ActiveState's PERL_OBJECT build
	      #
              (
	       $Config{archname} =~ /-object\b/i ?
	       ( CAPI => 'TRUE' ) : ()
	      ),
              #
              # On Win32, MakeMaker ain't picking up the constants.c.PL 
              # file for free.  Probably a bug... 
              #
	      (
	       $Config{osname} =~ /win32/i ?
	       (
		PL_FILES =>
		{
		 'constants.c.PL' 	=> 'constants.c',
		 'typemap.PL'     	=> 'typemap',
		}
	       ) : ()
	      )
	     );

# now we remove it again so that it will be out-of-date
# with respect to typemap.PL.
unlink("typemap");

#
# Unlink this to be force it to be regenerated.
#
unlink("constants.c");

