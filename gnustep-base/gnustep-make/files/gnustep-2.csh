#!@GENTOO_PORTAGE_EPREFIX@/bin/csh

# Test for an interactive shell
if ( $?prompt ) then

	setenv GNUSTEP_SYSTEM_TOOLS "@GENTOO_PORTAGE_EPREFIX@"/usr/GNUstep/System/Tools

	if ( -x $GNUSTEP_SYSTEM_TOOLS/make_services ) then
		$GNUSTEP_SYSTEM_TOOLS/make_services
	endif

	if ( -x $GNUSTEP_SYSTEM_TOOLS/gdnc ) then
		$GNUSTEP_SYSTEM_TOOLS/gdnc
	endif

endif
