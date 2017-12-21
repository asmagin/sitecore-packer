#!/bin/bash
openssl req -x509 -newkey rsa:2048 -days 3650 -nodes -out ca.cert
