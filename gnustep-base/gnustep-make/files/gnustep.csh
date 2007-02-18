#!/bin/csh

if ( -e /etc/GNUstep/GNUstep.conf ) then
    eval `sed -e '/^[^#=][^#=]*=.*$/\\!d' -e 's/^\([^#=][^#=]*\)=\(.*\)$/setenv \1 \2;/' /etc/GNUstep/GNUstep.conf`
else
    GNUSTEP_SYSTEM_ROOT="/usr/GNUstep/System"
endif

source $GNUSTEP_SYSTEM_ROOT/Library/Makefiles/GNUstep.csh

if ( -z "$GNUSTEP_FLATTENED" ) then
    set TDIR=${GNUSTEP_SYSTEM_ROOT}/Tools/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}/${LIBRARY_COMBO}
else
    set TDIR=${GNUSTEP_SYSTEM_ROOT}/Tools
endif

if ( -x $TDIR/make_services ) then
    $TDIR/make_services
endif

unset TDIR