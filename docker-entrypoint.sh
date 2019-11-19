#!/bin/bash

set -e

# Add npm as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- npm "$@"
fi

# Drop root privileges if we are running npm
# allow the container to be started with `--user`
if [ "$1" = 'npm' -a "$(id -u)" = '0' ]; then
	# Create user-mutable directories to npm logs and keys
    set -- su-exec node "$@"
fi

# As argument is not related to npm,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
