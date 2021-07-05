#!/bin/bash
echo "*** webrtc docker project installer ***\n\r"
if [ -e keys/front-selfsigned.key ] || [ -e keys/front-selfsigned.crt  ]; then
	read -p "cert file already exists. Do you want overwrite? (y/n)?" choice
	case "$choice" in 
 		 y|Y ) KEYOP="y";;
  		n|N ) KEYOP="n";;
  		* ) echo "invalid";;
	esac
fi

if ! [ -e keys/front-selfsigned.key ] || ! [ -e keys/front-selfsigned.crt  ] || [ $KEYOP = 'y' ]; then
    echo "Creating self certificate...\n\n\r Data are optional, when ask 'Common Name (e.g. server FQDN or YOUR name) []: your_local_ip_address_or_domain_addr_configured_into_hosts_file'";
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout keys/front-selfsigned.key -out keys/front-selfsigned.crt
fi

if ! [ -e keys/front-selfsigned.key ] || ! [ -e keys/front-selfsigned.crt  ]; then
    echo "*** cert files doesn't exists, that is needed to continue\n\r";
    exit 1;
fi
echo "Copying into nginx (nginx/cert)...\n\r"
cp -f keys/front-selfsigned.key nginx/cert/ && cp -f keys/front-selfsigned.crt nginx/cert/
echo "Copying into php/janus (php/cert)...\n\r"
cp -f keys/front-selfsigned.key php/cert/ && cp -f keys/front-selfsigned.crt php/cert/





echo "\n\n\n Now you can run 'docker-compose build'\n after that I recommend change the ownership of folder 'files' to you \$user "
