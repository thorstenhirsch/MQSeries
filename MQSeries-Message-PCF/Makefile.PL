#
# $Id: Makefile.PL,v 14.1 2000/08/15 20:50:56 wpm Exp $
#
# (c) 1999, 2000 Morgan Stanley Dean Witter and Co.
# See ..../src/LICENSE for terms of distribution.
#

use ExtUtils::MakeMaker;

require "../util/parse_config";
require "../util/parse_headers";

WriteMakefile(
	      NAME	   	=> 'MQSeries::Message::PCF',
	      VERSION_FROM	=> 'PCF.pm',
	      INC		=> qq{-I"$include"},
              (
	       $Config{archname} =~ /-object\b/i ?
	       (
		CAPI 		=> 'TRUE',
	       ) : ()
	      )
	     );

