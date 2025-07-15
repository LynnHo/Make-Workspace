#!/bin/bash

pid=$(pgrep -P $1 | head -1)
if [ -z "$pid" ]; then
    echo " [ $(date '+%Y/%m/%d %H:%M') ] "
fi

cmd=$(ps -o cmd --no-headers --pid $pid)
etime=$(ps -o etime --no-headers --pid $pid | awk '{print $1}')
if [ -n "$cmd" ]; then
    echo " [ PID: $1 • ETIME: $etime >> $cmd ] "
fi
