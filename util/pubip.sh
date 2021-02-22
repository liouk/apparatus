#!/usr/bin/env bash

known_ip=$(cat ./known_ip)
ip=$(curl -s icanhazip.com)

echo -n "${ip}"
if [[ "$ip" != "$known_ip" ]]; then
  echo -n " (!)"
fi
