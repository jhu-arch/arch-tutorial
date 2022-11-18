#!/bin/bash
if [[ ( $1 == *"c"* ) ]]; then
   echo $2 | openssl enc -aes-192-cbc -md sha512 -a -pbkdf2 -iter 100000 -salt -pass pass:Secret@123# --out $3
   exit 0
fi

if [[ ( $1 == *"d"* ) ]];  then
   openssl enc -aes-192-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:Secret@123# -in $2
else
   echo "No arg valid !"
fi
