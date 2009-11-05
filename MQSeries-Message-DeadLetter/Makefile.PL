#
# $Id: Makefile.PL,v 33.2 2009/07/10 18:30:34 biersma Exp $
#
# (c) 1999-2009 Morgan Stanley & Co. Incorporated
# See ..../src/LICENSE for terms of distribution.
#

use ExtUtils::MakeMaker;

require "../util/parse_config";
require "../util/parse_headers";
require "../util/fake_mm";

WriteMakefile(NAME	   	=> 'MQSeries::Message::DeadLetter',
	      VERSION_FROM 	=> 'DeadLetter.pm',
	      INC		=> qq{-I"$include"},
	      (
	       $Config{archname} =~ /-object\b/i ?
	       (
		CAPI	=> 'TRUE',
	       ) : ()
	      )
	     );
