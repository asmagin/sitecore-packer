#!/bin/bash
openssl req -newkey rsa:2048 -nodes -out $1/$1.csr -keyout $1/$1.key -config $1/$1.conf
