#
# $Id: Makefile.PL,v 16.1 2001/01/05 21:43:08 wpm Exp $
#
# (c) 1999-2001 Morgan Stanley Dean Witter and Co.
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
	       $^O eq 'os390' ?
	       (
		MAN3PODS	=> {},
	       ) : ()
	      ),
              (
	       $Config{archname} =~ /-object\b/i ?
	       (
		CAPI 		=> 'TRUE',
	       ) : ()
	      )
	     );

