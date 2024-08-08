#!/bin/bash

# Unless explicitly stated otherwise all files in this repository are licensed
# under the Apache License Version 2.0.
# This product includes software developed at Datadog (https://www.datadoghq.com/)
# Copyright 2022-present Datadog, Inc.

mkdir .datadog

# $LANGUAGES or $DD_CIVISIBILITY_INSTRUMENTATION_LANGUAGES are required
if [[ -z "$LANGUAGES" && -z "$DD_CIVISIBILITY_INSTRUMENTATION_LANGUAGES" ]]; then
	>&2 echo "LANGUAGES is not set"
	exit 1
fi

# $SITE or $DD_SITE are required
if [[ -z "$SITE" && -z "$DD_SITE" ]]; then
	>&2 echo "SITE is not set"
	exit 1
elif [ -n "$SITE" ]; then
	echo "export DD_SITE=${SITE}"
fi

# $API_KEY or $DD_API_KEY are required
if [[ -z "$API_KEY" && -z "$DD_API_KEY" ]]; then
	>&2 echo "API_KEY is not set"
	exit 1
elif [ -n "$API_KEY" ]; then
	echo "export DD_API_KEY=${API_KEY}"
fi

# $SERVICE or $DD_SERVICE are optional
if [ -n "$SERVICE" ]; then
	echo "export DD_SERVICE=${SERVICE}"
fi

# $DOTNET_TRACER_VERSION or $DD_SET_TRACER_VERSION_DOTNET are optional
if [ -n "$DOTNET_TRACER_VERSION" ]; then
	echo "export DD_SET_TRACER_VERSION_DOTNET=${DOTNET_TRACER_VERSION}"
fi

# $JAVA_TRACER_VERSION or $DD_SET_TRACER_VERSION_JAVA are optional
if [ -n "$JAVA_TRACER_VERSION" ]; then
	echo "export DD_SET_TRACER_VERSION_JAVA=${JAVA_TRACER_VERSION}"
fi

# $JS_TRACER_VERSION or $DD_SET_TRACER_VERSION_JS are optional
if [ -n "$JS_TRACER_VERSION" ]; then
	echo "export DD_SET_TRACER_VERSION_JS=${JS_TRACER_VERSION}"
fi

# $PYTHON_TRACER_VERSION or $DD_SET_TRACER_VERSION_PYTHON are optional
if [ -n "$PYTHON_TRACER_VERSION" ]; then
	echo "export DD_SET_TRACER_VERSION_PYTHON=${PYTHON_TRACER_VERSION}"
fi

# $JAVA_INSTRUMENTED_BUILD_SYSTEM or $DD_INSTRUMENTATION_BUILD_SYSTEM_JAVA are optional
if [ -n "$JAVA_INSTRUMENTED_BUILD_SYSTEM" ]; then
	echo "export DD_INSTRUMENTATION_BUILD_SYSTEM_JAVA=${JAVA_INSTRUMENTED_BUILD_SYSTEM}"
fi


installation_script_url="https://raw.githubusercontent.com/DataDog/test-visibility-install-script/4b0d47cc7308a176c4a2d3f5d629418fc0fd8590/install_test_visibility.sh"  #TODO: Change once we fix the bug with the original install script
script_filepath="install_test_visibility.sh"
installation_script_checksum="123"

if command -v curl >/dev/null 2>&1; then
	curl -Lo "$script_filepath" "$installation_script_url"
elif command -v wget >/dev/null 2>&1; then
	wget -O "$script_filepath" "$installation_script_url"
else
	>&2 echo "Error: Neither wget nor curl is installed."
	return 1
fi

if ! echo "$installation_script_checksum $script_filepath" | sha256sum --quiet -c -; then
	>&2 echo "Error: The checksum of the downloaded script does not match the expected checksum."
        return 1
fi

chmod +x ./install_test_visibility.sh

DD_CIVISIBILITY_AUTO_INSTRUMENTATION_PROVIDER="gitlab" DD_CIVISIBILITY_INSTRUMENTATION_LANGUAGES="${LANGUAGES}" ./install_test_visibility.sh | while IFS= read -r line; do echo "export $line"; done

# Without echoing export and sed and evaling
#eval $(DD_SITE="datad0g.com" DD_CIVISIBILITY_INSTRUMENTATION_LANGUAGES="js" DD_API_KEY="test123" ./script.sh | sed 's/^/export /')

# Echoing export and just evaling
#eval $(DD_SITE="datad0g.com" DD_CIVISIBILITY_INSTRUMENTATION_LANGUAGES="js" DD_API_KEY="test123" ./script.sh)
