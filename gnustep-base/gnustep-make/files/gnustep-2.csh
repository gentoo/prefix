#!/bin/csh

# Test for an interactive shell
if ( $?prompt ) then

	setenv GNUSTEP_SYSTEM_TOOLS /usr/GNUstep/System/Tools

	if ( -x $GNUSTEP_SYSTEM_TOOLS/make_services ) then
		$GNUSTEP_SYSTEM_TOOLS/make_services
	endif

	if ( -x $GNUSTEP_SYSTEM_TOOLS/gdnc ) then
		$GNUSTEP_SYSTEM_TOOLS/gdnc
	endif

endif
