#!/bin/bash
#
# PCAP browsing information extraction
#
# Example to take a PCAP and extract as much behaviour about browsing behaviour as possible
#
# Currently uses a lot of temporary files, but can be tidied up later


PCAP="$1"
TMPDIR="/tmp/pcapanalysis.$$"
MYDIR=`dirname $0`



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
      -e 's/0XC0AC/TLS_ECDHE_ECDSA_WITH_AES_128_CCM/gi' \
      -e 's/0XC0AD/TLS_ECDHE_ECDSA_WITH_AES_256_CCM/gi' \
      -e 's/0XC0AE/TLS_ECDHE_ECDSA_WITH_AES_128_CCM_8/gi' \
      -e 's/0XC0AF/TLS_ECDHE_ECDSA_WITH_AES_256_CCM_8/gi' \
      -e 's/0x002C/TLS_PSK_WITH_NULL_SHA/gi' \
      -e 's/0x002D/TLS_DHE_PSK_WITH_NULL_SHA/gi' \
      -e 's/0x002E/TLS_RSA_PSK_WITH_NULL_SHA/gi' \
      -e 's/0x0096/TLS_RSA_WITH_SEED_CBC_SHA/gi' \
      -e 's/0x0097/TLS_DH_DSS_WITH_SEED_CBC_SHA/gi' \
      -e 's/0x0098/TLS_DH_RSA_WITH_SEED_CBC_SHA/gi' \
      -e 's/0x0099/TLS_DHE_DSS_WITH_SEED_CBC_SHA/gi' \
      -e 's/0x009A/TLS_DHE_RSA_WITH_SEED_CBC_SHA/gi' \
      -e 's/0x009B/TLS_DH_anon_WITH_SEED_CBC_SHA/gi' \
      -e 's/0x0003/TLS_RSA_EXPORT_WITH_RC4_40_MD5/gi' \
      -e 's/0x0006/TLS_RSA_EXPORT_WITH_RC2_CBC_40_MD5/gi' \
      -e 's/0x0008/TLS_RSA_EXPORT_WITH_DES40_CBC_SHA/gi' \
      -e 's/0x000B/TLS_DH_DSS_EXPORT_WITH_DES40_CBC_SHA/gi' \
      -e 's/0x000E/TLS_DH_RSA_EXPORT_WITH_DES40_CBC_SHA/gi' \
      -e 's/0x0011/TLS_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA/gi' \
      -e 's/0x0014/TLS_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA/gi' \
      -e 's/0x0017/TLS_DH_anon_EXPORT_WITH_RC4_40_MD5/gi' \
      -e 's/0x0019/TLS_DH_anon_EXPORT_WITH_DES40_CBC_SHA/gi' \
      -e 's/0x0007/TLS_RSA_WITH_IDEA_CBC_SHA/gi' \
      -e 's/0x0009/TLS_RSA_WITH_DES_CBC_SHA/gi' \
      -e 's/0x000C/TLS_DH_DSS_WITH_DES_CBC_SHA/gi' \
      -e 's/0x000F/TLS_DH_RSA_WITH_DES_CBC_SHA/gi' \
      -e 's/0x0012/TLS_DHE_DSS_WITH_DES_CBC_SHA/gi' \
      -e 's/0x0015/TLS_DHE_RSA_WITH_DES_CBC_SHA/gi' \
      -e 's/0x001A/TLS_DH_anon_WITH_DES_CBC_SHA/gi' \
      -e 's/0x001E/TLS_KRB5_WITH_DES_CBC_SHA/gi' \
      -e 's/0x001F/TLS_KRB5_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0x0020/TLS_KRB5_WITH_RC4_128_SHA/gi' \
      -e 's/0x0021/TLS_KRB5_WITH_IDEA_CBC_SHA/gi' \
      -e 's/0x0022/TLS_KRB5_WITH_DES_CBC_MD5/gi' \
      -e 's/0x0023/TLS_KRB5_WITH_3DES_EDE_CBC_MD5/gi' \
      -e 's/0x0024/TLS_KRB5_WITH_RC4_128_MD5/gi' \
      -e 's/0x0025/TLS_KRB5_WITH_IDEA_CBC_MD5/gi' \
      -e 's/0x0026/TLS_KRB5_EXPORT_WITH_DES_CBC_40_SHA/gi' \
      -e 's/0x0027/TLS_KRB5_EXPORT_WITH_RC2_CBC_40_SHA/gi' \
      -e 's/0x0028/TLS_KRB5_EXPORT_WITH_RC4_40_SHA/gi' \
      -e 's/0x0029/TLS_KRB5_EXPORT_WITH_DES_CBC_40_MD5/gi' \
      -e 's/0x002A/TLS_KRB5_EXPORT_WITH_RC2_CBC_40_MD5/gi' \
      -e 's/0x002B/TLS_KRB5_EXPORT_WITH_RC4_40_MD5/gi' \
      -e 's/0x0041/TLS_RSA_WITH_CAMELLIA_128_CBC_SHA/gi' \
      -e 's/0x0042/TLS_DH_DSS_WITH_CAMELLIA_128_CBC_SHA/gi' \
      -e 's/0x0043/TLS_DH_RSA_WITH_CAMELLIA_128_CBC_SHA/gi' \
      -e 's/0x0044/TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA/gi' \
      -e 's/0x0045/TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA/gi' \
      -e 's/0x0046/TLS_DH_anon_WITH_CAMELLIA_128_CBC_SHA/gi' \
      -e 's/0x0084/TLS_RSA_WITH_CAMELLIA_256_CBC_SHA/gi' \
      -e 's/0x0085/TLS_DH_DSS_WITH_CAMELLIA_256_CBC_SHA/gi' \
      -e 's/0x0086/TLS_DH_RSA_WITH_CAMELLIA_256_CBC_SHA/gi' \
      -e 's/0x0087/TLS_DHE_DSS_WITH_CAMELLIA_256_CBC_SHA/gi' \
      -e 's/0x0088/TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA/gi' \
      -e 's/0x0089/TLS_DH_anon_WITH_CAMELLIA_256_CBC_SHA/gi' \
      -e 's/0x008A/TLS_PSK_WITH_RC4_128_SHA/gi' \
      -e 's/0x008B/TLS_PSK_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0x008C/TLS_PSK_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0x008D/TLS_PSK_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0x008E/TLS_DHE_PSK_WITH_RC4_128_SHA/gi' \
      -e 's/0x008F/TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0x0090/TLS_DHE_PSK_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0x0091/TLS_DHE_PSK_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0x0092/TLS_RSA_PSK_WITH_RC4_128_SHA/gi' \
      -e 's/0x0093/TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0x0094/TLS_RSA_PSK_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0x0095/TLS_RSA_PSK_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0x00A8/TLS_PSK_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0x00A9/TLS_PSK_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0x00AA/TLS_DHE_PSK_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0x00AB/TLS_DHE_PSK_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0x00AC/TLS_RSA_PSK_WITH_AES_128_GCM_SHA256/gi' \
      -e 's/0x00AD/TLS_RSA_PSK_WITH_AES_256_GCM_SHA384/gi' \
      -e 's/0x00AE/TLS_PSK_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0x00AF/TLS_PSK_WITH_AES_256_CBC_SHA384/gi' \
      -e 's/0x00B0/TLS_PSK_WITH_NULL_SHA256/gi' \
      -e 's/0x00B1/TLS_PSK_WITH_NULL_SHA384/gi' \
      -e 's/0x00B2/TLS_DHE_PSK_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0x00B3/TLS_DHE_PSK_WITH_AES_256_CBC_SHA384/gi' \
      -e 's/0x00B4/TLS_DHE_PSK_WITH_NULL_SHA256/gi' \
      -e 's/0x00B5/TLS_DHE_PSK_WITH_NULL_SHA384/gi' \
      -e 's/0x00B6/TLS_RSA_PSK_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0x00B7/TLS_RSA_PSK_WITH_AES_256_CBC_SHA384/gi' \
      -e 's/0x00B8/TLS_RSA_PSK_WITH_NULL_SHA256/gi' \
      -e 's/0x00B9/TLS_RSA_PSK_WITH_NULL_SHA384/gi' \
      -e 's/0x00BA/TLS_RSA_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0x00BB/TLS_DH_DSS_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0x00BC/TLS_DH_RSA_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0x00BD/TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0x00BE/TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0x00BF/TLS_DH_anon_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0x00C0/TLS_RSA_WITH_CAMELLIA_256_CBC_SHA256/gi' \
      -e 's/0x00C1/TLS_DH_DSS_WITH_CAMELLIA_256_CBC_SHA256/gi' \
      -e 's/0x00C2/TLS_DH_RSA_WITH_CAMELLIA_256_CBC_SHA256/gi' \
      -e 's/0x00C3/TLS_DHE_DSS_WITH_CAMELLIA_256_CBC_SHA256/gi' \
      -e 's/0x00C4/TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA256/gi' \
      -e 's/0x00C5/TLS_DH_anon_WITH_CAMELLIA_256_CBC_SHA256/gi' \
      -e 's/0x00FF/TLS_EMPTY_RENEGOTIATION_INFO_SCSV/gi' \
      -e 's/0x5600/TLS_FALLBACK_SCSV/gi' \
      -e 's/0xC01A/TLS_SRP_SHA_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0xC01B/TLS_SRP_SHA_RSA_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0xC01C/TLS_SRP_SHA_DSS_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0xC01D/TLS_SRP_SHA_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0xC01E/TLS_SRP_SHA_RSA_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0xC01F/TLS_SRP_SHA_DSS_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0xC020/TLS_SRP_SHA_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0xC021/TLS_SRP_SHA_RSA_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0xC022/TLS_SRP_SHA_DSS_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0xC033/TLS_ECDHE_PSK_WITH_RC4_128_SHA/gi' \
      -e 's/0xC034/TLS_ECDHE_PSK_WITH_3DES_EDE_CBC_SHA/gi' \
      -e 's/0xC035/TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA/gi' \
      -e 's/0xC036/TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA/gi' \
      -e 's/0xC037/TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA256/gi' \
      -e 's/0xC038/TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA384/gi' \
      -e 's/0xC039/TLS_ECDHE_PSK_WITH_NULL_SHA/gi' \
      -e 's/0xC03A/TLS_ECDHE_PSK_WITH_NULL_SHA256/gi' \
      -e 's/0xC03B/TLS_ECDHE_PSK_WITH_NULL_SHA384/gi' \
      -e 's/0xC03C/TLS_RSA_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC03D/TLS_RSA_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC03E/TLS_DH_DSS_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC03F/TLS_DH_DSS_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC040/TLS_DH_RSA_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC041/TLS_DH_RSA_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC042/TLS_DHE_DSS_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC043/TLS_DHE_DSS_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC044/TLS_DHE_RSA_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC045/TLS_DHE_RSA_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC046/TLS_DH_anon_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC047/TLS_DH_anon_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC048/TLS_ECDHE_ECDSA_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC049/TLS_ECDHE_ECDSA_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC04A/TLS_ECDH_ECDSA_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC04B/TLS_ECDH_ECDSA_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC04C/TLS_ECDHE_RSA_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC04D/TLS_ECDHE_RSA_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC04E/TLS_ECDH_RSA_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC04F/TLS_ECDH_RSA_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC050/TLS_RSA_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC051/TLS_RSA_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC052/TLS_DHE_RSA_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC053/TLS_DHE_RSA_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC054/TLS_DH_RSA_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC055/TLS_DH_RSA_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC056/TLS_DHE_DSS_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC057/TLS_DHE_DSS_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC058/TLS_DH_DSS_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC059/TLS_DH_DSS_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC05A/TLS_DH_anon_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC05B/TLS_DH_anon_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC05C/TLS_ECDHE_ECDSA_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC05D/TLS_ECDHE_ECDSA_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC05E/TLS_ECDH_ECDSA_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC05F/TLS_ECDH_ECDSA_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC060/TLS_ECDHE_RSA_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC061/TLS_ECDHE_RSA_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC062/TLS_ECDH_RSA_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC063/TLS_ECDH_RSA_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC064/TLS_PSK_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC065/TLS_PSK_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC066/TLS_DHE_PSK_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC067/TLS_DHE_PSK_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC068/TLS_RSA_PSK_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC069/TLS_RSA_PSK_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC06A/TLS_PSK_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC06B/TLS_PSK_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC06C/TLS_DHE_PSK_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC06D/TLS_DHE_PSK_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC06E/TLS_RSA_PSK_WITH_ARIA_128_GCM_SHA256/gi' \
      -e 's/0xC06F/TLS_RSA_PSK_WITH_ARIA_256_GCM_SHA384/gi' \
      -e 's/0xC070/TLS_ECDHE_PSK_WITH_ARIA_128_CBC_SHA256/gi' \
      -e 's/0xC071/TLS_ECDHE_PSK_WITH_ARIA_256_CBC_SHA384/gi' \
      -e 's/0xC072/TLS_ECDHE_ECDSA_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0xC073/TLS_ECDHE_ECDSA_WITH_CAMELLIA_256_CBC_SHA384/gi' \
      -e 's/0xC074/TLS_ECDH_ECDSA_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0xC075/TLS_ECDH_ECDSA_WITH_CAMELLIA_256_CBC_SHA384/gi' \
      -e 's/0xC076/TLS_ECDHE_RSA_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0xC077/TLS_ECDHE_RSA_WITH_CAMELLIA_256_CBC_SHA384/gi' \
      -e 's/0xC078/TLS_ECDH_RSA_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0xC079/TLS_ECDH_RSA_WITH_CAMELLIA_256_CBC_SHA384/gi' \
      -e 's/0xC07A/TLS_RSA_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC07B/TLS_RSA_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC07C/TLS_DHE_RSA_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC07D/TLS_DHE_RSA_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC07E/TLS_DH_RSA_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC07F/TLS_DH_RSA_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC080/TLS_DHE_DSS_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC081/TLS_DHE_DSS_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC082/TLS_DH_DSS_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC083/TLS_DH_DSS_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC084/TLS_DH_anon_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC085/TLS_DH_anon_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC086/TLS_ECDHE_ECDSA_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC087/TLS_ECDHE_ECDSA_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC088/TLS_ECDH_ECDSA_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC089/TLS_ECDH_ECDSA_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC08A/TLS_ECDHE_RSA_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC08B/TLS_ECDHE_RSA_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC08C/TLS_ECDH_RSA_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC08D/TLS_ECDH_RSA_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC08E/TLS_PSK_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC08F/TLS_PSK_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC090/TLS_DHE_PSK_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC091/TLS_DHE_PSK_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC092/TLS_RSA_PSK_WITH_CAMELLIA_128_GCM_SHA256/gi' \
      -e 's/0xC093/TLS_RSA_PSK_WITH_CAMELLIA_256_GCM_SHA384/gi' \
      -e 's/0xC094/TLS_PSK_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0xC095/TLS_PSK_WITH_CAMELLIA_256_CBC_SHA384/gi' \
      -e 's/0xC096/TLS_DHE_PSK_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0xC097/TLS_DHE_PSK_WITH_CAMELLIA_256_CBC_SHA384/gi' \
      -e 's/0xC098/TLS_RSA_PSK_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0xC099/TLS_RSA_PSK_WITH_CAMELLIA_256_CBC_SHA384/gi' \
      -e 's/0xC09A/TLS_ECDHE_PSK_WITH_CAMELLIA_128_CBC_SHA256/gi' \
      -e 's/0xC09B/TLS_ECDHE_PSK_WITH_CAMELLIA_256_CBC_SHA384/gi' \
      -e 's/0xC09C/TLS_RSA_WITH_AES_128_CCM/gi' \
      -e 's/0xC09D/TLS_RSA_WITH_AES_256_CCM/gi' \
      -e 's/0xC09E/TLS_DHE_RSA_WITH_AES_128_CCM/gi' \
      -e 's/0xC09F/TLS_DHE_RSA_WITH_AES_256_CCM/gi' \
      -e 's/0xC0A0/TLS_RSA_WITH_AES_128_CCM_8/gi' \
      -e 's/0xC0A1/TLS_RSA_WITH_AES_256_CCM_8/gi' \
      -e 's/0xC0A2/TLS_DHE_RSA_WITH_AES_128_CCM_8/gi' \
      -e 's/0xC0A3/TLS_DHE_RSA_WITH_AES_256_CCM_8/gi' \
      -e 's/0xC0A4/TLS_PSK_WITH_AES_128_CCM/gi' \
      -e 's/0xC0A5/TLS_PSK_WITH_AES_256_CCM/gi' \
      -e 's/0xC0A6/TLS_DHE_PSK_WITH_AES_128_CCM/gi' \
      -e 's/0xC0A7/TLS_DHE_PSK_WITH_AES_256_CCM/gi' \
      -e 's/0xC0A8/TLS_PSK_WITH_AES_128_CCM_8/gi' \
      -e 's/0xC0A9/TLS_PSK_WITH_AES_256_CCM_8/gi' \
      -e 's/0xC0AA/TLS_PSK_DHE_WITH_AES_128_CCM_8/gi' \
      -e 's/0xC0AB/TLS_PSK_DHE_WITH_AES_256_CCM_8/gi' \
      -e 's/0XCC20/TLS_RSA_WITH_CHACHA20_SHA/gi' \
      -e 's/0XCC21/TLS_ECDHE_RSA_WITH_CHACHA20_SHA/gi' \
      -e 's/0XCC22/TLS_ECDHE_ECDSA_WITH_CHACHA20_SHA/gi' \
      -e 's/0XCC23/TLS_DHE_RSA_WITH_CHACHA20_SHA/gi' \
      -e 's/0XCC24/TLS_DHE_PSK_WITH_CHACHA20_SHA/gi' \
      -e 's/0XCC25/TLS_PSK_WITH_CHACHA20_SHA/gi' \
      -e 's/0XCC26/TLS_ECDHE_PSK_WITH_CHACHA20_SHA/gi' \
      -e 's/0XCC27/TLS_RSA_PSK_WITH_CHACHA20_SHA/gi' \
      -e 's/0XCC12/TLS_RSA_WITH_CHACHA20_POLY1305/gi' \
      -e 's/0XCC13/TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305/gi' \
      -e 's/0XCC14/TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305/gi' \
      -e 's/0XCC15/TLS_DHE_RSA_WITH_CHACHA20_POLY1305/gi' \
      -e 's/0XCC16/TLS_DHE_PSK_WITH_CHACHA20_POLY1305/gi' \
      -e 's/0XCC17/TLS_PSK_WITH_CHACHA20_POLY1305/gi' \
      -e 's/0XCC18/TLS_ECDHE_PSK_WITH_CHACHA20_POLY1305/gi' \
      -e 's/0XCC19/TLS_RSA_PSK_WITH_CHACHA20_POLY1305/gi'


}



# Load the config, if it exists
if [ -f "${MYDIR}/config.sh" ]
then
      source "${MYDIR}/config.sh"
fi

# This may have been set in config, we use a small default set - as much defined by test data as what's interesting
INTERESTING_PATHS=${INTERESTING_PATHS:-"(www|np|m|i)\.reddit\.com\/r\/([^\/]*)|www\.google\.|www\.bbc\.co\.uk"}


mkdir -p "$TMPDIR"
echo "Starting, using ${TMPDIR} for temp files"

STANDARD_FIELDS="-e frame.time_epoch -e ip.src -e ip.dst -e ipv6.src -e ipv6.dst -e tcp.srcport -e tcp.dstport"


echo "Extracting a list of Destination Ports"
# Build a unique list of Dest IP's and Ports (PAS-9) for TCP connections
tshark -q -r "$PCAP" -Y "(tcp.flags.syn == 1) && (tcp.flags.ack == 0)" -T fields $STANDARD_FIELDS > "${TMPDIR}/tcpsyns.txt"


# Grab the low hanging fruit
echo "Analysing Port 80 Traffic"
tshark -q -r "$PCAP" -Y "http.host" -T fields $STANDARD_FIELDS \
-e http.host -e http.request.method -e http.request.uri -e http.referer -e http.user_agent -e http.cookie -e http.authorization > "${TMPDIR}/httprequests.txt"

# Extract the HTTPs referrers for use later
grep "https://" "${TMPDIR}/httprequests.txt" > "${TMPDIR}/httpsreferers.txt"

echo "Analysing SSL/TLS traffic"
# Extract information from the SSL/TLS sessions we can see
tshark -q -r "$PCAP" -Y "ssl.handshake" -T fields $STANDARD_FIELDS \
-e ssl.handshake.extensions_server_name -e ssl.handshake.ciphersuite > "${TMPDIR}/sslrequests.txt"



echo "Identifying HTTPS pages from HTTP Referrers"
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


# Extract interesting referers (PAS-3)
cat "${TMPDIR}/httprequests.txt" | awk -F'	' -v OFS='\t' '{print $11,"HTTP Referer"}' | egrep -e "$INTERESTING_PATHS" | sort | uniq > "${TMPDIR}/interestingurls.csv"

# Extract interesting URL paths
cat "${TMPDIR}/httprequests.txt" | awk -F'	' -v OFS='\t' '{print $8$10,"HTTP Request"}' | sed 's/"//g' | egrep -e "$INTERESTING_PATHS" | sort | uniq >> "${TMPDIR}/interestingurls.csv"


echo "Looking for XMPP traffic"
tshark -q -r "$PCAP" -Y "xmpp" -T fields $STANDARD_FIELDS > "${TMPDIR}/xmpprequests.txt"


# Will work on pick out some extra information later, for now, let's combine into a report
echo "Building reports"
REPORTDIR="report.$PCAP.`date +'%s'`"
mkdir $REPORTDIR

# Build webtraffic.csv
cat ${TMPDIR}/httprequests.txt | while read -r line
do
      ts=$(echo "$line" | awk -F '	' '{print $1}')
      srcip=$(echo "$line" | awk -F '	' '{print $2}')
      destip=$(echo "$line" | awk -F '	' '{print $3}')
      srcip6=$(echo "$line" | awk -F '	' '{print $4}')
      destip6=$(echo "$line" | awk -F '	' '{print $5}')
      srcport=$(echo "$line" | awk -F '	' '{print $6}')
      destport=$(echo "$line" | awk -F '	' '{print $7}')
      fqdn=$(echo "$line" | awk -F '	' '{print $8}')
      reqmethod=$(echo "$line" | awk -F '	' '{print $9}')
      requri=$(echo "$line" | awk -F '	' '{print $10}')
      referer=$(echo "$line" | awk -F '	' '{print $11}')
      useragent=$(echo "$line" | awk -F '	' '{print $12}')
      cookie=$(echo "$line" | awk -F '	' '{print $13}')
      auth=$(echo "$line" | awk -F '	' '{print $14}')

      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t"%s"\t"%s"\t"%s"\t"%s"\t"%s"\t%s\t\t"%s"\t\n' "$ts" "$srcip" "$destip" "$srcip6" "$destip6" "$srcport" \
      "$destport" "$fqdn" "$reqmethod" "$requri" "$referer" "$useragent" "$cookie" "$auth" >> "${REPORTDIR}/webtraffic.csv"

done

# Add SSL/TLS traffic to webtraffic.csv
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
      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t"%s"\t\t\t\t\t\t"%s"\t"%s"\t\n' "$ts" "$srcip" "$destip" "$srcip6" "$destip6" "$srcport" \
      "$destport" "$sniname" "$sniname" "$ciphersuites" >> "${REPORTDIR}/webtraffic.csv"
done

# Sort the entries
sort -n -o "${REPORTDIR}/webtraffic.csv" "${REPORTDIR}/webtraffic.csv"


if [ -f ${TMPDIR}/site.information.* ]
then

cat << EOM > "${REPORTDIR}/ssltraffic.txt"
Known Pages within SSL Sites
------------------------------
    `for i in ${TMPDIR}/site.information.*; do cat "$i"; done`

EOM

fi


# Extract associated IP's
for ip in `cat ${TMPDIR}/*requests.txt | awk -F '	' '{print $2}{print $3}{print $4}{print $5}' | sort | uniq`
do

      PTR=`host "$ip" | tr '\n' ' '`
      printf '%s,"%s",\n' "$ip" "$PTR" >> "${REPORTDIR}/associatedhosts.csv"

done


# Extract cookies
cat ${TMPDIR}/httprequests.txt | awk -F '	' '{print $13}' | sed 's~; ~\n~g' | sed 's/=/\t/' |sort | uniq > "${REPORTDIR}/observedcookies.csv"

# Extract User-agents
cat ${TMPDIR}/httprequests.txt | awk -F '	' '{print $12}' | sort | uniq > "${REPORTDIR}/observedhttpuseragents.csv"

# Built the list of known FQDNs
cat ${TMPDIR}/httprequests.txt ${TMPDIR}/sslrequests.txt | awk -F '	' '{print $8}' | sort | uniq > "${REPORTDIR}/visitedsites.csv"

# Extract any identified username/passwords
cat ${TMPDIR}/httprequests.txt | awk -F '	' '{print $14}' | awk 'NF' | while read -r line
do
  type=$(echo "$line" | awk -F' ' '{print $1}')
  if [ "$type" == "Basic" ]
  then
      value=$(echo -n "$line" | awk -F' ' '{print $2}' | base64 -d)
      username=$(echo "$value" | cut -d\: -f1)
      pass=$(echo "$value" | cut -d\: -f2)
  else
      # Will deal with Digest etc later
      continue
  fi

  printf "%s\t%s\t%s\t%s\n" "$type" "$username" "$pass" "HTTP" >> "${REPORTDIR}/observedcredentials.csv"

done


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
