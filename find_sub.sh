#!/bin/bash

# Check if the correct number of arguments are passed
if [ $# -eq 0 ]; then
    echo "Usage: ./find_sub <domain>"
    echo "Example: ./find_sub www.megacorpone.com"
    exit 1
fi

DOMAIN=$1

# Fetch the webpage and extract the subdomains
wget -q $DOMAIN -O index.html
if [ $? -ne 0 ]; then
    echo "Failed to retrieve the webpage for $DOMAIN"
    exit 1
fi

grep "href" index.html | cut -d ":" -f 2 | cut -d "/" -f 3 | grep "mega" | cut -d '"' -f 1 | grep $DOMAIN | uniq > sub.txt
rm index.html

# Initialize valid_sub.txt and ips.txt
> valid_sub.txt
> ips.txt

# Check the validity of subdomains and save the valid ones
while read -r sub_itr; do
    if ping -c 1 "$sub_itr" &> /dev/null; then
        echo "$sub_itr +++ Pong"
        echo "$sub_itr" >> valid_sub.txt
    else
        echo "$sub_itr +++ Error"
    fi
done < sub.txt

# Resolve IP addresses of valid subdomains
while read -r ip; do
    host "$ip" | awk '/has address/ { print $4 }' | uniq >> ips.txt
done < valid_sub.txt

# Cleanup temporary files
rm sub.txt valid_sub.txt

