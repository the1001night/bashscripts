#!/bin/bash
cat /dev/urandom | md5sum & 
cat /dev/urandom | md5sum & 
dd if=/dev/zero of=testfile bs=1M count=1024 oflag=direct &

