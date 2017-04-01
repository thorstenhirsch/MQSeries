# MQSeries Perl Module
[![GitHub version](https://cdn.rawgit.com/thorstenhirsch/MQSeries/master/img/version.svg)](https://github.com/thorstenhirsch/MQSeries)

## INTRODUCTION
This module implements a perl5 API for the IBM MQSeries / WebSphere MQ
messaging middleware product API (often referred to as the MQI), as well
as:

* Object Oriented (OO) interface to the MQI
* OO interface to the MQSeries administrative commands via PCF or MQSC
* OO interface to the various configuration, log, and error files

For more information on the MQSeries / WebSphere MQ product itself, see
the IBM website at: http://www.ibm.com/software/products/en/ibm-mq

## PREREQUISITES
This release requires Perl 5.8 or later, and a current release of IBM MQ
(formerly known as Websphere MQ and MQSeries) installed, either V5.2
(+ high CSD), V5.3, V6.0, V7.0, 7.1, 7.5, 8.0, or 9.0.

## PLATFORMS
This package has been known to build with the following combinations of
software. Those marked with an asterix (\*) are platforms the maintainers
can not test personally, so there is a remote possibility that there may
be new bugs in these platforms. Please report problems to the
maintainers.

```
    Operating System        MQSeries Version        Perl Version
    ================        ================        ============
   *SunOS 5.7               5.2                     5.8
   *SunOS 5.7               5.3                     Same as SunOS 5.7 / MQ 5.2
   *SunOS 5.8               5.2                     Same as SunOS 5.7 / MQ 5.2
   *SunOS 5.8               5.3                     Same as SunOS 5.7 / MQ 5.2
   *SunOS 5.8               6.0                     5.8
   *SunOS 5.9               5.3                     Same as SunOS 5.7 / MQ 5.2
   *SunOS 5.8               7.0                     5.10
   *SunOS 5.10              7.1                     5.10
    SunOS 5.11              8.0                     5.18
   *AIX 5.1L                6.0                     5.8
   *AIX 5.3                 6.0.2                   5.8
   *Red Hat AS 3.0 / ia32   5.3                     5.8
   *Red Hat EL 4 / ia32     5.3                     5.8
   *Red Hat EL 4 / ia32     6.0                     5.8
   *Red Hat EL 4 / ia32     7.0                     5.8
   *Red Hat EL 4 / x86_64   6.0                     5.8
   *Red Hat EL 4 / x86_64   7.0                     5.8
   *Red Hat EL 5 / x86_64   6.0.2                   5.8
   *Red Hat EL 5 / x86_64   7.0                     5.8
   *Red Hat EL 5 / x86_64   7.1                     5.8
    Red Hat EL 6 / x86_64   8.0                     5.22
    Red Hat EL 7 / x86_64   8.0                     5.24
    Red Hat EL 7 / x86_64   9.0                     5.24
   *HP-UX 11.31 Itanium     7.0                     5.8.9
   *Windows XP SP2          5.3                     Active Perl 5.8.8
   *Windows XP SP2          6.0                     Active Perl 5.8.8
   *Windows Server 2003     5.3                     Active Perl 5.8.8
   *Windows Server 2003     6.0                     Active Perl 5.8.8
```

If you succeed in making this work on any other platform, please send
the changes (in the form of a context diff) to the authors, so we can
integrate them.

## INSTALLATION
This module installs much like anything else available on CPAN.

```bash
perl Makefile.PL
make
make test
make install
```

On Windows with Visual C++ 8.0, you may need to configure a manifest
file. See README.windows for more details.

Before building the module, you need to edit the CONFIG file and change,
minimally, the name of the queue manager against which the tests will
run. The rest of the defaults should be reasonable, but you will have to
customize this file to match your local environment. The CONFIG file has
comments which document each of the parameters, so go read it for more
information.

On some platforms (notably Linux and HP-UX), you need to link to
different libraries depending on whether your perl has been set up to
run multi-theaded or not. The MQClient/Makefile.PL script tries to
figure this out automatically; if you run into issues, patches to that
script will be welcome.

You will obviously need to create the queue used for the test suite on
the queue manager you specified in the CONFIG file.

NOTE: If you do not support client channel table files, then you may
have to set the MQSERVER environment variable in order to allow the
client tests to work.

Any failure in the test suite should a cause for concern. In order to
get more details from it, run it via:

```bash
make test TEST_VERBOSE=1
```

If you can't figure out what broke, then send the author the output from
"perl -V", as well as the output from the verbose test run. Please
include as many details as possible about the operating system and
MQSeries software on both the host being used to compile this extension,
as well as the queue manager to which the test suite is connecting.

The most common problem with this module is failure to connect to the
queue manager. Before submitting a bug report for the MQClient::MQSeries
modules, make sure the IBM-supplied sample utilities `amqsgetc' and
`amqsputc' work.

## RELEASE NOTES
The Changes.html file has a complete, historical list of all
user-visible (and some invisible) changes to this code.

## WARNINGS REGARDING WMQ V6 PCF SUPPORT
You should be warned this release does not contain support for every new
PCF command made available in V6. The following are not supported in
this release:

Inquire Archive Inquire ChannelInitiator Inquire EntityAuthority Inquire
Group Inquire Log Inquire System Move Queue Refresh QueueManager Reset
QueueManager Resume QueueManager Set Archive Set Log Set System Stop
ChannelInitiator Suspend QueueManager

You should be warned not all new PCF commands which are supported in
this release have been throughly tested by the maintainers. New PCF
commands which have been throughly tested include:

Change/Copy/Create/Inquire/Delete/Stop ChannelListener
Change/Copy/Create/Inquire/Delete/Start/Stop Service Inquire
ChannelListenerStatus Inquire QueueManagerStatus Inquire ServiceStatus

Though we believe the rest to work just fine.

You should be warned 'filtering' is not supported in this release. You
will not be able to specify parameters such as 'IntegerFilterCommand',
'StringFilterCommand' or 'ByteStringFilterCommand' for those objects
where filtering has been made available.

## DOCUMENTATION
The documentation will be installed as man pages by default, but the
location of them depends entirely on how you have perl built and
installed. Watch the installation, and you will see where they get
installed. Prepend that to your MANPATH environment variable, and then,
all of these man commands will work.

Personally, the author prefers the results of "pod2html", but the perl5
Makefile.PL infrastructure won't do this for you automatically.

```bash
man MQSeries
```

will provide the documentation for the core MQI interface, and,

```bash
man MQSeries::QueueManager
man MQSeries::Queue
man MQSeries::Message
```

will provide the core documentation for the OO interface.

The following man pages document the classes that handle various special
MQSeries message types:

```bash
man MQSeries::Message::Event
man MQSeries::Message::Storable
man MQSeries::Message::PCF
man MQSeries::Message::DeadLetter
```

There is an OO interface to the Command Server:

```bash
man MQSeries::Command
man MQSeries::Command::Request
man MQSeries::Command::Response
```

A number of utility classes have been created for parsing the various
file formats used by the MQSeries product:

```bash
man MQSeries::Config::ChannelTable
man MQSeries::Config::Machine
man MQSeries::Config::QMgr
man MQSeries::ErrorLog::Parser
man MQSeries::ErrorLog::Tail
man MQSeries::ErrorLog::Entry
man MQSeries::FDC::Parser
man MQSeries::FDC::Tail
man MQSeries::FDC::Entry
```

## AUTHORS
The code is currently maintained and supported by:

> Thorsten Hirsch <t-dot-hirsch(at)web-dot-de>

Most of the previous development, maintenance and support work was done by:

> MQ Engineering Group at Morgan Stanley
> Hildo Biersma
> W. Phillip Moore

We also have to give credit to:

> Brian T. Shelden <shelden@shelden-associates.com>

for his help in porting and testing the code.

This module was originally developed as an IBM SupportPac, so credit
must also go to the original author:

> David J. Lennon <davidl@bristol.com>

Although, nothing remains of the original code.... (sorry, David :-)
