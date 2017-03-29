#
# (c) 1999-2012 Morgan Stanley & Co. Incorporated
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
