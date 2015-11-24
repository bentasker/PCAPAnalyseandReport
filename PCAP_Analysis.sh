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
echo "Starting, using ${TMPDIR} for temp files"

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
# Now lets see if we can pick out some of the URLs visited on HTTPs sites. Disabled (and replaced) for PAS-2
#cat "${TMPDIR}/sslrequests.txt" | awk -F '	' '{print $6}' | sort | uniq | while read -r sslhost
#do
#
#      if [ "$sslhost" == "" ]
#      then
#	    continue
#      fi
#
#      lines=`grep "https://$sslhost" "${TMPDIR}/httpsreferers.txt"`
#
#      linecount=`echo -n "${lines}" |wc -l`
#      if [ "$linecount" == 0 ]
#      then
#	  continue
#      fi
#
#      echo "$sslhost" > "${TMPDIR}/site.information.$sslhost"
#      echo "" >> "${TMPDIR}/site.information.$sslhost"
#      echo "${lines}" >> "${TMPDIR}/site.information.$sslhost"
#done


# Introduced for PAS-2
# Extract HTTPS referrers from Port 80 requests and gather identified URL paths
cat "${TMPDIR}/httpsreferers.txt" | awk -F '	' '{print $9}' | egrep -o 'https:\/\/([^\/]*)' | sort | uniq | sed 's~https://~~g' | while read -r sslhost
do

      lines=`cat "${TMPDIR}/httpsreferers.txt" | awk -F '	' '{print $9}' | grep -n "https://$sslhost"`

      linecount=`echo -n "${lines}" |wc -l`
      if [ "$linecount" == 0 ]
      then
	  continue # This should never happen
      fi

      echo "$sslhost" > "${TMPDIR}/site.information.$sslhost"
      echo "" >> "${TMPDIR}/site.information.$sslhost"
      for lineno in `echo "${lines}" | cut -d\: -f1`
      do
      		sed -n ${lineno}p "${TMPDIR}/httpsreferers.txt" >> "${TMPDIR}/site.information.$sslhost"
      done

done



echo "Looking for XMPP traffic"
tshark -q -r "$PCAP" -Y "tcp.dstport == 5222" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport > "${TMPDIR}/xmpprequests.txt"


# Will work on pick out some extra information later, for now, let's combine into a report


echo "Building reports"
REPORTDIR="report.$PCAP.`date +'%s'`"
mkdir $REPORTDIR


# Build the webtraffic CSV
echo > "${REPORTDIR}/webtraffic.csv" # Might drop a header row in here later
cat ${TMPDIR}/httprequests.txt >> "${REPORTDIR}/webtraffic.csv"
cat ${TMPDIR}/sslrequests.txt | while read -r line
do
      ts=$(echo "$line" | awk -F '	' '{print $1}')
      srcip=$(echo "$line" | awk -F '	' '{print $2}')
      destip=$(echo "$line" | awk -F '	' '{print $3}')
      srcport=$(echo "$line" | awk -F '	' '{print $4}')
      destport=$(echo "$line" | awk -F '	' '{print $5}')
      sniname=$(echo "$line" | awk -F '	' '{print $6}')
      ciphersuites=$(echo "$line" | awk -F '	' '{print $7}')
      printf "%s\t%s\t%s\t%s\t%s\t%s\t\t\t\t\t\t%s\t%s\n" "$ts" "$srcip" "$destip" "$srcport" \
      "$destport" "$sniname" "$sniname" "$ciphersuites" >> "${REPORTDIR}/webtraffic.csv"
done

# Sort the entries
sort -n -o "${REPORTDIR}/webtraffic.csv" "${REPORTDIR}/webtraffic.csv"




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


echo "Done- Reports in ${REPORTDIR}"
# TODO: Once finished testing, need to tidy the tempdirs away
