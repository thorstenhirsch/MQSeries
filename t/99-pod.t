#
# $Id: 99-pod.t,v 33.3 2011/01/03 15:05:03 anbrown Exp $
#
# (c) 2009-2011 Morgan Stanley & Co. Incorporated
# See ..../src/LICENSE for terms of distribution.
#

#
# Morgan Stanley versioning - ignore
#
BEGIN {
    if ($ENV{ID_EXEC}) {
	require "MSDW/Version.pm";
	MSDW::Version->import('Test-Pod'    => '1.20',
			      'Test-Simple' => '0.60',
			      'Pod-Escapes' => '1.04',
			      'Pod-Simple'  => '3.04',
			     );
    }
}
use Test::More;
eval "use Test::Pod";
plan skip_all => "Test::Pod required for testing POD" if ($@);
all_pod_files_ok("MQSeries.pm", all_pod_files('MQSeries'));
