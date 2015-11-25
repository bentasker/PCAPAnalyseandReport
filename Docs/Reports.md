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


ssltraffic.txt  
----------------

This file contains details of all HTTPS hosts where visited paths have been identified (usually from the referrer header when leaving a HTTPS domain for a HTTP one)


visitedsites.csv  
------------------

This file contains sorted and unique FQDNs for all sites visited via either HTTP or HTTPS. It currently contains one field - FQDN - but may later be updated to include an indicator as to whether HTTP or HTTPS was used.


webtraffic.csv  
----------------

This file contains a chronologically ordered list of all traffic observed on either Port 80 (HTTP) or anything with a TLS handshake (so HTTPS, IMAPS etc)

As of PAS-10, fields are as follows

      epoch,ipv4 src ip,ipv4 dest ip, ipv6 src ip, ipv6 dest ip,src port, dest port, FQDN, HTTP request method, Request Path, HTTP Referer, HTTP useragent, http cookie, SNI Server name, SSL/TLS ciphersuite(s)



xmpppeers.csv
--------------

A list of all peers observed using XMPP port 5222
