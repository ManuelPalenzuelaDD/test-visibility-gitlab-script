#!/bin/bash

mkdir .datadog

export DD_SITE=$DD_SITE
export DD_SERVICE=$DD_SERVICE
export DD_API_KEY=$DD_API_KEY

url="https://install.datadoghq.com/scripts/install_test_visibility_v1.sh"
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

DD_CIVISIBILITY_AUTO_INSTRUMENTATION_PROVIDER="gitlab" ./install_test_visibility.sh | while IFS= read -r line; do export "$line"; done
