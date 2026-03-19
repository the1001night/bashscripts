#!/bin/bash
( exit 0 ) &
CHILD_PID=$!

echo "Ребенок $CHILD_PID завершен. Родитель $$ жив."
kill -STOP $$
