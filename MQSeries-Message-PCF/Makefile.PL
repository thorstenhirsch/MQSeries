#
# $Id: Makefile.PL,v 12.1 2000/02/18 03:16:51 wpm Exp $
#
# (c) 1999 Morgan Stanley Dean Witter and Co.
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

