#!/bin/bash

set -e

if [ "$1" = 'ucc-bin' ]; then
    # Put cdkey in place
    echo $CDKEY > /usr/src/ut2004/System/cdkey
fi

exec "$@"
