#!/bin/bash
#
# PCAP browsing information extraction
#
# Example to take a PCAP and extract as much behaviour about browsing behaviour as possible
#
# Currently uses a lot of temporary files, but can be tidied up later


PCAP="$1"
TMPDIR="/tmp/pcapanalysis.$$"

mkdir -p "$TMPDIR"

# Grab the low hanging fruit
echo "Analysing Port 80 Traffic"
tshark -q -r "$PCAP" -Y "http.host" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e http.host \
-e http.request.method -e http.request.uri -e http.referer -e http.user_agent -e http.cookie > "${TMPDIR}/httprequests.txt"

# Extract the HTTPs referrers for use later
grep "https://" "${TMPDIR}/httprequests.txt" > "${TMPDIR}/httpsreferers.txt"

echo "Analysing HTTPS traffic"
# Extract information from the SSL/TLS sessions we can see
tshark -q -r "$PCAP" -Y "ssl.handshake" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport \
-e ssl.handshake.extensions_server_name -e ssl.handshake.ciphersuite > "${TMPDIR}/sslrequests.txt"

echo "Identifying HTTPS pages from HTTP Referrers"
# Now lets see if we can pick out some of the URLs visited on HTTPs sites
cat "${TMPDIR}/sslrequests.txt" | awk -F '	' '{print $6}' | sort | uniq | while read -r sslhost
do

      if [ "$sslhost" == "" ]
      then
	    continue
      fi

      lines=`grep "https://$sslhost" "${TMPDIR}/httpsreferers.txt"`

      linecount=`echo -n "${lines}" |wc -l`
      if [ "$linecount" == 0 ]
      then
	  continue
      fi

      echo "$sslhost" > "${TMPDIR}/site.information.$sslhost"
      echo "" >> "${TMPDIR}/site.information.$sslhost"
      echo "${lines}" >> "${TMPDIR}/site.information.$sslhost"
done


echo "Looking for XMPP traffic"
tshark -q -r "$PCAP" -Y "tcp.dstport == 5222" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport > "${TMPDIR}/xmpprequests.txt"


# Will work on pick out some extra information later, for now, let's combine into a report


echo "Building reports"
REPORTDIR="report.$PCAP.`date +'%s'`"
mkdir $REPORTDIR


cat << EOM > "${REPORTDIR}/webtraffic.csv"
    `cat ${TMPDIR}/httprequests.txt ${TMPDIR}/sslrequests.txt | sort -n`

EOM


cat << EOM > "${REPORTDIR}/ssltraffic.txt"
Known Pages within SSL Sites
------------------------------
    `for i in ${TMPDIR}/site.information.*; do cat "$i"; done`

EOM

# Extract associated IP's
for ip in `cat ${TMPDIR}/*requests.txt | awk -F '	' '{print $2}{print $3}' | sort | uniq`
do

      PTR=`host "$ip" | tr '\n' ' '`
      printf '%s,"%s",\n' "$ip" "$PTR" >> "${REPORTDIR}/associatedhosts.csv"

done


# Extract cookies
cat ${TMPDIR}/httprequests.txt | awk -F '	' '{print $11}' | sed 's~; ~\n~g' | sort | uniq > "${REPORTDIR}/observedcookies.csv"

# Extract User-agents
cat ${TMPDIR}/httprequests.txt | awk -F '	' '{print $10}' | sort | uniq > "${REPORTDIR}/observedhttpuseragents.csv"

cat ${TMPDIR}/httprequests.txt ${TMPDIR}/sslrequests.txt | awk -F '	' '{print $6}' | sort | uniq > "${REPORTDIR}/visitedsites.csv"

# Pull out details of who (if anyone) has been contacted using XMPP
for ip in `cat "${TMPDIR}/xmpprequests.txt" | awk -F '	' '{print $2}{print $3}' | sort | uniq`
do
    echo "$ip," >> "${REPORTDIR}/xmpppeers.csv"
done


echo "Done"
# TODO: Once finished testing, need to tidy the tempdirs away
