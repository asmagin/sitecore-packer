#!/bin/bash
openssl ca -batch -config ca.conf -notext -in $1/$1.csr -out $1/$1.cert
