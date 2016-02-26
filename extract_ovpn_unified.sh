#!/bin/bash

function usage {
  echo "Extracts certificates and keys from unified OpenVPN .ovpn file."
  echo "Saves original .ovpn and private key file with .orig extension added."
  echo
  echo "Command:"
  echo "$0 [options] <unified ovpn file>"
  echo
  echo "Options:"
  echo "  -p     : Add passphrase to private key file"
  echo "  -h     : Show help text"
  echo "  --help : Show help text"
  echo
  echo "Example:"
  echo "  If input file is myovpn.ovpn, then"
  echo
  echo "  extract_ovpn_unified.sh -p myovpn.ovpn"
  echo
  echo "  creates the following files:"
  echo "  - myovpn.ovpn"
  echo "  - myovpn_ca.pem"
  echo "  - myovpn_cert.pem"
  echo "  - myovpn_key.pem"
  echo "  - myovpn_tls_auth.key"
  echo
  echo "  and adds/changes passphrase for myovpn_key.pem."
  exit
}

if [ -z $1 ]; then
  usage
  exit
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  usage
  exit
elif [ "$1" = "-p" ] && [ -z $2 ]; then
  usage
  exit 1
elif [ "$1" = "-p" ]; then
  add_pass=1
  infile=$2
else
  infile=$1
fi

if [ ! -f $infile ]; then
  echo "No such file: $infile"
  exit
fi

base_name=`echo $infile | cut -d. -f1`
new_ovpn=$infile".new"
of=$new_ovpn

while IFS='' read -r line || [[ -n "$line" ]]; do
  if [ "$line" = "<ca>" ]; then
    of=$base_name"_ca.pem"
    echo "ca $of" >> $new_ovpn
  elif [ "$line" = "<cert>" ]; then
    of=$base_name"_cert.pem"
    echo "cert $of" >> $new_ovpn
  elif [ "$line" = "<key>" ]; then
    of=$base_name"_key.pem"
    echo "key $of" >> $new_ovpn
  elif [ "$line" = "<tls-auth>" ]; then
    of=$base_name"_tls_auth.key"
    echo "tls-auth $of 1" >> $new_ovpn
  elif [ "$line" = "</ca>" ] || [ "$line" = "</cert>" ] || [ "$line" = "</key>" ] || [ "$line" = "</tls-auth>" ]; then
    of=$new_ovpn
  else
    echo $line >> $of
  fi
done < "$infile"

mv $infile $infile".orig"
mv $infile".new" $infile

if [ ! -z $add_pass ]; then
  echo "Adding passphrase to private key:"
  openssl rsa -des3 -in $base_name"_key.pem" -out newkey.pem
  mv $base_name"_key.pem" $base_name"_key.pem.orig"
  mv newkey.pem $base_name"_key.pem"
fi
