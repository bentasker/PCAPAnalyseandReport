Report Files
==============

This documentation details the report files generated, what they represent and the field structure used (where appropriate)

All CSVs are tab seperated.


associatedhosts.csv  
---------------------

This file details all unique IP's identified within the PCAP. Each row contains one field - IP


dest-ip-ports.csv  
---------------------

This file contains a list of all unique IP and destination ports identified.

Fields are

      Dest IP, Dest Port, Tunnelled,Proto

Where Tunnelled has the following values/meanings

* For both native IPv4 and IPv6, Tunnelled will be N
* For IPv4 encapsulated IPv6, Tunnelled will be Y
* For IPv4 addresses identified as a tunnel endpoint, port will be empty and Tunnelled will be T

Proto will likely be 

* TCP or
* UDP

Though may include others in the future


httpspaths.csv
----------------

In [PAS-19](http://projects.bentasker.co.uk/jira_projects/browse/PAS-19.html) this report replaced the old [ssltraffic.csv](https://github.com/bentasker/PCAPAnalyseandReport/blob/b7e36ffb25e248ae4c0c8a0fa525843eff99262c/Docs/Reports.md#ssltraffictxt--)

This file contains details of all HTTPS hosts where visited paths have been identified (usually from the referrer header when leaving a HTTPS domain for a HTTP one)

Fields are

    FQDN, Url Path identified


interestingdomains.csv
-----------------------

A single column CSV containing a list of unique matches to interesting domains - see [Interesting Referers/Paths](https://github.com/bentasker/PCAPAnalyseandReport/blob/master/Docs/OverridingConfiguration.md#interesting-refererspaths) for more information on how these are configured and identified

This CSV contains only the portion of each request/header which precisely matched the regex used. So matching a regex of *google.com* would result in google.com being recorded in this CSV

See also *interestingdomains-full.csv*


interestingdomains-full.csv
-----------------------------

A multi column CSV containing a list of matches to interesting domains - see [Interesting Referers/Paths](https://github.com/bentasker/PCAPAnalyseandReport/blob/master/Docs/OverridingConfiguration.md#interesting-refererspaths) for more information on how these are configured and identified.

Unlike *interestingdomains.csv* this CSV contains the full value of the header which matched the regex. So with a regex of *google.com* the value google.com/search/?q=foo might be recorded.

The CSV consists of 3 columns

    Header value, Match type, Time observed

Where Match type will be one of the following

* HTTP Referer - Match was found in a Referer header
* HTTP Request - A HTTP request was found matching the regex (either the requested path, or the Host header)
* GA Cookie - A path was extracted from a Google analytics cookie

Note that at time of writing, the GA Cookie entries do not use the configured Regex's.


mailtransactions.csv
----------------------

Contains a time ordered list of all SMTP commands observed

Fields are

    Epoch, Source IPv4, Dest IPv4, Source IPv6, Dest IPv6, Source Port, Dest Port, SMTP Command, SMTP Parameter, Username, Password


observedcookies.csv  
---------------------

This file contains a sorted and unique list of all cookies identified in HTTP sessions.

Fields are

    Cookie Name, Value


observedcredentials.csv
-------------------------

Contains credentials extracted from plaintext communications. Currently limited to HTTP Basic authentication, but will later be expanded to include SMTP Plain amongst others

Fields are

    AuthType Username Pass Source

For example

    Basic   foo     mypass     HTTP



observedhttpuseragents.csv
----------------------------

This file contains a sorted and unique list of all user-agents identified in HTTP sessions


tcptraffic.csv
---------------

This file is a CSV containing observed TCP flags in chronological order. Fields are

    Epoch, ipv4 src ip,ipv4 dest ip, ipv6 src ip, ipv6 dest ip,src port, dest port, Flags

Where flags will be FIN, SYN, SYN/ACK etc.

Used correctly, the flags can be used to identify information about the connection they correspond to (for example to identify likely HTTP Keep-alive timeout periods within a HTTPS connection).

Assuming multipurpose fields are not a concern, if desried, this file can safely be merged with webtraffic.csv by doing the following

    cat webtraffic.csv tcptraffic.csv | sort > merged.csv

Field 8 of the new file will either contain an FQDN or the relevant TCP flag.


unresolvabledomains.csv
-------------------------

This file is a CSV containing traffic data for any FQDN that was observed but could not be resolved (suggesting either a non-advertised service or connection to a Tor-like service)

Fields are

    IPv4 src ip, ipv4 dest ip, ipv6 src ip, ipv6 dest ip, src port, dest port, SNI Name, Certificate names

The information provided is still limited, but is currently being developed under [PAS-26](http://projects.bentasker.co.uk/jira_projects/browse/PAS-26.html)

visitedsites.csv  
------------------

This file contains sorted and unique FQDNs for all sites visited via either HTTP or HTTPS. It currently contains two fields

* FQDN
* Observed Source (e.g. HTTP Host Header, SNI Handshake etc)


webtraffic.csv  
----------------

This file contains a chronologically ordered list of all traffic observed on either Port 80 (HTTP) or anything with a TLS handshake (so HTTPS, IMAPS etc)

Fields are as follows

      epoch,ipv4 src ip,ipv4 dest ip, ipv6 src ip, ipv6 dest ip,src port, dest port, FQDN, HTTP request method, Request Path, HTTP Referer, HTTP useragent, http cookie, SNI Server name, SSL/TLS ciphersuite(s), Authentication Token



xmpppeers.csv
--------------

A list of all peers observed using XMPP port 5222
