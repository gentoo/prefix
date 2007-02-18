#!/bin/sh

if [ -e /etc/GNUstep/GNUstep.conf ]
    then
    . /etc/GNUstep/GNUstep.conf
else
    GNUSTEP_SYSTEM_ROOT="/usr/GNUstep/System"
fi

. $GNUSTEP_SYSTEM_ROOT/Library/Makefiles/GNUstep.sh

if [ -z "$GNUSTEP_FLATTENED" ] 
    then
    TDIR=${GNUSTEP_SYSTEM_ROOT}/Tools/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}/${LIBRARY_COMBO}
else
    TDIR=${GNUSTEP_SYSTEM_ROOT}/Tools
fi

if [ -x $TDIR/make_services ]
    then
    $TDIR/make_services
fi

