Report Files
==============

This documentation details the report files generated, what they represent and the field structure used (where appropriate)



associatedhosts.csv  
---------------------

This file details all unique IP's identified within the PCAP. Each row contains one field - IP


observedcookies.csv  
---------------------

This file contains a sorted and unique list of all cookies identified in HTTP sessions. Each row currently contains one field - Cookie.

Note: this will likely be split later into two fields, Cookie name and Value


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

Fields currently differ depending on the port used - this will be addressed in future


xmpppeers.csv
--------------

A list of all peers observed using XMPP port 5222
