#!/bin/bash
curl -s   --form-string "token=$2"   --form-string "user=$1"   --form-string "message=$3"   https://api.pushover.net/1/messages.json
