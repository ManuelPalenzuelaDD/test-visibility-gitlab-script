#!/bin/bash

# Unless explicitly stated otherwise all files in this repository are licensed
# under the Apache License Version 2.0.
# This product includes software developed at Datadog (https://www.datadoghq.com/)
# Copyright 2022-present Datadog, Inc.

mkdir .datadog

if [ -z "$DD_CIVISIBILITY_INSTRUMENTATION_LANGUAGES" ]; then
  >&2 echo "DD_CIVISIBILITY_INSTRUMENTATION_LANGUAGES is not set"
  exit 1
fi

if [ -z "$DD_SITE" ]; then
  >&2 echo "DD_SITE is not set"
  exit 1
else
  echo "export DD_SITE=${DD_SITE}"
fi


if [ -z "$DD_API_KEY" ]; then
  >&2 echo "DD_API_KEY is not set"
  exit 1
else
  echo "export DD_API_KEY=${DD_API_KEY}"
fi

# $DD_SERVICE is optional
if [ -n "$DD_SERVICE" ]; then
  echo "export DD_SERVICE=${DD_SERVICE}"
fi


url="https://raw.githubusercontent.com/DataDog/test-visibility-install-script/4b0d47cc7308a176c4a2d3f5d629418fc0fd8590/install_test_visibility.sh"  #TODO: Change once we fix the bug with the original install script
filepath="install_test_visibility.sh"

if command -v curl >/dev/null 2>&1; then
	curl -Lo "$filepath" "$url"
elif command -v wget >/dev/null 2>&1; then
	wget -O "$filepath" "$url"
else
	>&2 echo "Error: Neither wget nor curl is installed."
	return 1
fi

chmod +x ./install_test_visibility.sh

DD_CIVISIBILITY_AUTO_INSTRUMENTATION_PROVIDER="gitlab" ./install_test_visibility.sh | while IFS= read -r line; do echo "export $line"; done

# Without echoing export and sed and evaling
#eval $(DD_SITE="datad0g.com" DD_CIVISIBILITY_INSTRUMENTATION_LANGUAGES="js" DD_API_KEY="test123" ./script.sh | sed 's/^/export /')

# Echoing export and just evaling
#eval $(DD_SITE="datad0g.com" DD_CIVISIBILITY_INSTRUMENTATION_LANGUAGES="js" DD_API_KEY="test123" ./script.sh)
