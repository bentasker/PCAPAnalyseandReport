#!/bin/bash
#
# PCAP browsing information extraction
#
# Example to take a PCAP and extract as much behaviour about browsing behaviour as possible
#
# Currently uses a lot of temporary files, but can be tidied up later


PCAP="$1"
TMPDIR="/tmp/pcapanalysis.$$"




function humanise_ciphers(){
# Not hugely proud of this function, but it does the job
line=$1

      echo "$line" | sed -e 's/0xC001/TLS_ECDH_ECDSA_WITH_NULL_SHA/gi' \
      -e 's/0xC002/TLS_ECDH_ECDSA_WITH_RC4_128_SHA/gi' \
      -e 's/0xC003/TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0xC004/TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0xC005/TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0xC006/TLS_ECDHE_ECDSA_WITH_NULL_SHA/gi' \
      -e 's/0xC007/TLS_ECDHE_ECDSA_WITH_RC4_128_SHA/gi' \
      -e 's/0xC008/TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0xC009/TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0xC00A/TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0xC00B/TLS_ECDH_RSA_WITH_NULL_SHA/gi' \
      -e 's/0xC00C/TLS_ECDH_RSA_WITH_RC4_128_SHA/gi' \
      -e 's/0xC00D/TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0xC00E/TLS_ECDH_RSA_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0xC00F/TLS_ECDH_RSA_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0xC010/TLS_ECDHE_RSA_WITH_NULL_SHA/gi' \
      -e 's/0xC011/TLS_ECDHE_RSA_WITH_RC4_128_SHA/gi' \
      -e 's/0xC012/TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0xC013/TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0xC014/TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0xC015/TLS_ECDH_anon_WITH_NULL_SHA/gi' \
      -e 's/0xC016/TLS_ECDH_anon_WITH_RC4_128_SHA/gi' \
      -e 's/0xC017/TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0xC018/TLS_ECDH_anon_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0xC019/TLS_ECDH_anon_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0x0000/TLS_NULL_WITH_NULL_NULL/gi' \
      -e 's/0x0001/TLS_RSA_WITH_NULL_MD5/gi' \
      -e 's/0x0002/TLS_RSA_WITH_NULL_SHA/gi' \
      -e 's/0x003B/TLS_RSA_WITH_NULL_SHA256/gi' \
      -e 's/0x0004/TLS_RSA_WITH_RC4_128_MD5/gi' \
      -e 's/0x0005/TLS_RSA_WITH_RC4_128_SHA/gi' \
      -e 's/0x000A/TLS_RSA_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0x002F/TLS_RSA_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0x0035/TLS_RSA_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0x003C/TLS_RSA_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0x003D/TLS_RSA_WITH_AES_256_CBC_SHA256/gi' \
      -e 's/0x000D/TLS_DH_DSS_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0x0010/TLS_DH_RSA_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0x0013/TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0x0016/TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0x0030/TLS_DH_DSS_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0x0031/TLS_DH_RSA_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0x0032/TLS_DHE_DSS_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0x0033/TLS_DHE_RSA_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0x0036/TLS_DH_DSS_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0x0037/TLS_DH_RSA_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0x0038/TLS_DHE_DSS_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0x0039/TLS_DHE_RSA_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0x003E/TLS_DH_DSS_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0x003F/TLS_DH_RSA_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0x0040/TLS_DHE_DSS_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0x0067/TLS_DHE_RSA_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0x0068/TLS_DH_DSS_WITH_AES_256_CBC_SHA256/gi' \
      -e 's/0x0069/TLS_DH_RSA_WITH_AES_256_CBC_SHA256/gi' \
      -e 's/0x006A/TLS_DHE_DSS_WITH_AES_256_CBC_SHA256/gi' \
      -e 's/0x006B/TLS_DHE_RSA_WITH_AES_256_CBC_SHA256/gi' \
      -e 's/0x0018/TLS_DH_anon_WITH_RC4_128_MD5/gi' \
      -e 's/0x001B/TLS_DH_anon_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0x0034/TLS_DH_anon_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0x003A/TLS_DH_anon_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0x006C/TLS_DH_anon_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0x006D/TLS_DH_anon_WITH_AES_256_CBC_SHA256/gi' \
      -e 's/0x009C/TLS_RSA_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0x009D/TLS_RSA_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0x009E/TLS_DHE_RSA_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0x009F/TLS_DHE_RSA_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0x00A0/TLS_DH_RSA_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0x00A1/TLS_DH_RSA_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0x00A2/TLS_DHE_DSS_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0x00A3/TLS_DHE_DSS_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0x00A4/TLS_DH_DSS_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0x00A5/TLS_DH_DSS_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0x00A6/TLS_DH_anon_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0x00A7/TLS_DH_anon_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0xC023/TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0xC024/TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384/gi' \
      -e 's/0xC025/TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0xC026/TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384/gi' \
      -e 's/0xC027/TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0xC028/TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384/gi' \
      -e 's/0xC029/TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0xC02A/TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384/gi' \
      -e 's/0xC02B/TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0xC02C/TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0xC02D/TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0xC02E/TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0xC02F/TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0xC030/TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0xC031/TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0xC032/TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384/gi' \


}








mkdir -p "$TMPDIR"
echo "Starting, using ${TMPDIR} for temp files"

STANDARD_FIELDS="-e frame.time_epoch -e ip.src -e ip.dst -e ipv6.src -e ipv6.dst -e tcp.srcport -e tcp.dstport"


echo "Extracting a list of Destination Ports"
# Build a unique list of Dest IP's and Ports (PAS-9) for TCP connections
tshark -q -r "$PCAP" -Y "(tcp.flags.syn == 1) && (tcp.flags.ack == 0)" -T fields $STANDARD_FIELDS > "${TMPDIR}/tcpsyns.txt"


# Grab the low hanging fruit
echo "Analysing Port 80 Traffic"
tshark -q -r "$PCAP" -Y "http.host" -T fields $STANDARD_FIELDS \
-e http.host -e http.request.method -e http.request.uri -e http.referer -e http.user_agent -e http.cookie > "${TMPDIR}/httprequests.txt"

# Extract the HTTPs referrers for use later
grep "https://" "${TMPDIR}/httprequests.txt" > "${TMPDIR}/httpsreferers.txt"

echo "Analysing SSL/TLS traffic"
# Extract information from the SSL/TLS sessions we can see
tshark -q -r "$PCAP" -Y "ssl.handshake" -T fields $STANDARD_FIELDS \
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
cat "${TMPDIR}/httpsreferers.txt" | awk -F '	' '{print $11}' | egrep -o 'https:\/\/([^\/]*)' | sort | uniq | sed 's~https://~~g' | while read -r sslhost
do

      lines=`cat "${TMPDIR}/httpsreferers.txt" | awk -F '	' '{print $11}' | grep -n "https://$sslhost"`

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
tshark -q -r "$PCAP" -Y "xmpp" -T fields $STANDARD_FIELDS > "${TMPDIR}/xmpprequests.txt"


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
      srcip6=$(echo "$line" | awk -F '	' '{print $4}')
      destip6=$(echo "$line" | awk -F '	' '{print $5}')
      srcport=$(echo "$line" | awk -F '	' '{print $6}')
      destport=$(echo "$line" | awk -F '	' '{print $7}')
      sniname=$(echo "$line" | awk -F '	' '{print $8}')
      ciphersuites=$(humanise_ciphers `echo "$line" | awk -F '	' '{print $9}'`)
      printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\t\t\t\t\t%s\t%s\n" "$ts" "$srcip" "$destip" "$srcip6" "$destip6" "$srcport" \
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
for ip in `cat ${TMPDIR}/*requests.txt | awk -F '	' '{print $2}{print $3}{print $4}{print $5}' | sort | uniq`
do

      PTR=`host "$ip" | tr '\n' ' '`
      printf '%s,"%s",\n' "$ip" "$PTR" >> "${REPORTDIR}/associatedhosts.csv"

done


# Extract cookies
cat ${TMPDIR}/httprequests.txt | awk -F '	' '{print $13}' | sed 's~; ~\n~g' | sort | uniq > "${REPORTDIR}/observedcookies.csv"

# Extract User-agents
cat ${TMPDIR}/httprequests.txt | awk -F '	' '{print $12}' | sort | uniq > "${REPORTDIR}/observedhttpuseragents.csv"

# Built the list of known FQDNs
cat ${TMPDIR}/httprequests.txt ${TMPDIR}/sslrequests.txt | awk -F '	' '{print $8}' | sort | uniq > "${REPORTDIR}/visitedsites.csv"



# Build the IP/port list (PAS-9)

# Start with native IPv4
cat "${TMPDIR}/tcpsyns.txt" | awk -F'	' 'length($2) && length($3)&& !length($4) && !length($5)' | awk -F '	' -v OFS='\t' '{print $3,$7,"N","TCP"}' | sort | uniq > "${REPORTDIR}/dest-ip-ports.csv"
# Native IPv6
cat "${TMPDIR}/tcpsyns.txt" | awk -F'	' '!length($2) && !length($3)&& length($4) && length($5)' | awk -F '	' -v OFS='\t' '{print $5,$7,"N","TCP"}' | sort | uniq >> "${REPORTDIR}/dest-ip-ports.csv"
# Tunnelled IPv6
cat "${TMPDIR}/tcpsyns.txt" | awk -F'	' 'length($2) && length($3)&& length($4) && length($5)' | awk -F '	' -v OFS='\t' '{print $5,$7,"Y","TCP"}' | sort | uniq >> "${REPORTDIR}/dest-ip-ports.csv"
# IPv4 endpoints for IPv6 Tunnels
cat "${TMPDIR}/tcpsyns.txt" | awk -F'	' 'length($2) && length($3)&& length($4) && length($5)' | awk -F '	' -v OFS='\t' '{print $3,"","T","TCP"}' | sort | uniq >> "${REPORTDIR}/dest-ip-ports.csv"


# Pull out details of who (if anyone) has been contacted using XMPP
for ip in `cat "${TMPDIR}/xmpprequests.txt" | awk -F '	' '{print $2}{print $3}{print $4}{print $5}' | sort | uniq`
do
    echo "$ip," >> "${REPORTDIR}/xmpppeers.csv"
done


echo "Done- Reports in ${REPORTDIR}"
# TODO: Once finished testing, need to tidy the tempdirs away
