#
# $Id: Makefile.PL,v 25.1 2004/01/14 19:10:14 biersma Exp $
#
# (c) 1999-2004 Morgan Stanley Dean Witter and Co.
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

