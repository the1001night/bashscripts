#!/bin/bash
sudo nice -n -10 cat /dev/urandom > /dev/null &
nice -n 0 cat /dev/urandom > /dev/null &
nice -n 19 cat /dev/urandom > /dev/null &

pgrep -fl cat
