#!/bin/bash
cat /dev/urandom | md5sum & 
cat /dev/urandom | md5sum & 
pv /dev/zero > /dev/null & 
dd if=/dev/zero of=testfile bs=1M count=1024 oflag=direct &
