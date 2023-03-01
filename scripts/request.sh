#!/bin/bash

function req {
	while [ true ]
	do
		RSP=`$NOTECARD $1`
		ERR=`echo $RSP | jq .err`
		if [[ "$ERR" == null ]]; then break; fi
		sleep 1
	done
}
