#!/bin/bash

cd /usr/local/cpanel

# Pull the host key
tmp_host_key=`cat etc/cloudflare.json | grep host_key | cut -d "\"" -f 4`
host_key=""
if [ -e /usr/local/cpanel/bin/apikeywrap ]; then
    host_key=`/usr/local/cpanel/bin/apikeywrap $tmp_host_key`
else 
    host_key=$tmp_host_key
fi
host_formal_name=`cat etc/cloudflare.json | grep host_formal_name | cut -d "\"" -f 4`
if [ "$host_key" == "" ]; then
    echo "error -- can not find a valid host key"
    exit 10
fi

# Pull the latest version down
dir=`perl Cpanel/CloudFlare.pm check | tail -1`

# If a new file exists, install it
if [ ! -d cloudflare_tmp ] && [ -e "$dir/cloudflare.tar.gz" ] && [ `stat -c %u $dir/cloudflare.tar.gz` -eq 0 ]; then
    mkdir cloudflare_tmp
    mv /$dir/cloudflare.tar.gz cloudflare_tmp/
    cd cloudflare_tmp
    tar -zxf cloudflare.tar.gz
    mv */cloudflare .
    cd cloudflare
    ./install_cf $host_key mod_cf "${host_formal_name}"

    # Cleanup
    cd /usr/local/cpanel
    rm -rf $dir
    rm -rf cloudflare_tmp
fi