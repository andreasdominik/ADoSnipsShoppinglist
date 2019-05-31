#!/bin/bash
#
JSON="$1"
INTENT="$(cat $JSON | grep -o 'andreasdominik:[a-zA-Z0-9]*')"
TOPIC="hermes/intent/$INTENT"

mosquitto_pub -t "$TOPIC" -f $JSON
