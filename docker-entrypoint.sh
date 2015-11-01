#!/bin/bash

set -e

if [ "$1" = 'ucc-bin' ]; then
    # Put cdkey in place
    echo $CDKEY > cdkey
    envtpl UT2004.ini.tpl
fi

exec "$@"
