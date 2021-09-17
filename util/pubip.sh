#!/usr/bin/env bash

workdir=$(dirname "$0")
known_ip=$(cat $workdir/known_ip)
ip=$(curl -s icanhazip.com)

echo -n "${ip}"
if [[ "$ip" != "$known_ip" ]]; then
  echo -n " (!)"
fi
