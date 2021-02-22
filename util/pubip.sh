#!/usr/bin/env bash

known_ip="51.154.64.217"
ip=$(curl -s icanhazip.com)

echo -n "${ip}"
if [[ "$ip" != "$known_ip" ]]; then
  echo -n " (!)"
fi
