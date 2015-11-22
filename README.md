# PCAP Analyse and Report

**Work in Progress**

PCAP Analyse and Report is a BASH wrapper for [tshark](https://www.wireshark.org/docs/man-pages/tshark.html) with the aim of extracting information about behaviour observed within a given PCAP and presenting in a simple format.

At time of writing the information extracted includes

* HTTP Sites visited (including URL Path requested)
* HTTPS Sites visited
* Paths known to have been visited on HTTPS sites
* XMPP servers connected to
* Unique list of cookies observed

The script will output a CSV containing port 80 and 443 traffic, as well as several text files containing metadata (Cookies, User-agents etc) extracted from that traffic.

