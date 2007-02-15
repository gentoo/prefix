# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/rox.eclass,v 1.20 2007/02/09 17:27:39 lack Exp $

# ROX eclass Version 2

# This eclass was created by Sergey Kuleshov (svyatogor@gentoo.org) and
# Alexander Simonov (devil@gentoo.org.ua) to ease installation of ROX desktop
# applications. Enhancements and python additions by Peter Hyman.
# Small fixes and current maintenance by the Rox herd (rox@gentoo.org)

# These variables are used in the GLOBAL scope to decide on DEPENDs, so they
# must be set BEFORE you 'inherit rox':
#
# ROX_VER - the minimum version of rox filer required. Default is 2.1.0
# ROX_LIB_VER - version of rox-lib required if any
# ROX_CLIB_VER - version of rox-clib required if any
#
# These variables are only used in local scopes, and so may be set anywhere in
# the ebuild:
#
# APPNAME - the actual name of the application as the app folder is named
# WRAPPERNAME - the name of the wrapper installed into /usr/bin
#    Defaults to 'rox-${PN}', or just ${PN} if it already starts with 'rox'.
#    This does not normally need to be overridden.
# APPNAME_COLLISION - If not set, the old naming convention for wrappers of
#    /usr/bin/${APPNAME} will still be around.  Needs only be set in packages
#    with known collisions (such as Pager, which collides with afterstep)
# APPCATEGORY - the .desktop categories this application should be placed in.
#    If unset, no .desktop file will be created.  For a list of acceptable
#    category names, see
#    http://standards.freedesktop.org/menu-spec/latest/apa.html
# KEEP_SRC - this flag, if set, will not remove the source directory
#    but will do a make clean in it. This is useful if users wish to
#    preserve the source code for some reason

# For examples refer to ebuilds in rox-extra/ or rox-base/

# need python to byte compile modules, if any
# need autotools to run autoreconf, if required
inherit python autotools eutils

if [[ -z "${ROX_VER}" ]]; then
	ROX_VER="2.1.0"
fi

RDEPEND=">=rox-base/rox-${ROX_VER}"

if [[ -n "${ROX_LIB_VER}" ]]; then
	RDEPEND="${RDEPEND}
		>=rox-base/rox-lib-${ROX_LIB_VER}"
fi

if [[ -n "${ROX_CLIB_VER}" ]]; then
	RDEPEND="${RDEPEND}
		>=rox-base/rox-clib-${ROX_CLIB_VER}"
	DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.20"
fi

# This is the new wrapper name (for /usr/bin/)
#   It is also used for the icon name in /usr/share/pixmaps
#
# Use rox-${PN} unless ${PN} already starts with 'rox'
a="rox-${PN}"
b=${a/rox-rox*}
WRAPPERNAME=${b:-${PN}}

# This is the location where all applications are installed
APPDIR="/usr/lib/rox"
LIBDIR="/usr/lib"

# Utility Functions

# Creates a .desktop file for this rox application
# (Adapted from eutils::make_desktop_entry)
#
# rox_desktop_entry <exec> <name> <icon> <type> [<extra> ...]
#  exec - The executable to run
#  name - The name to display
#  icon - The icon file to display
#  Any other arguments will be appended verbatim to the desktop file.
#
# The name of the desktop file will be ${exec}.desktop
#
rox_desktop_entry() {
	# Coppied from etuils:make_desktop_entry
	local exec=${1}; shift
	local name=${1}; shift
	local icon=${1}; shift
	local type=${1}; shift

	local desktop="${exec}.desktop"

	cat <<-EOF > "${desktop}"
	[Desktop Entry]
	Encoding=UTF-8
	Version=1.0
	Name=${name}
	Type=Application
	Comment=${DESCRIPTION}
	Exec=${exec}
	TryExec=${exec%% *}
	Icon=${icon}
	Categories=ROX;Application;${type};
	EOF

	local extra=${1}; shift
	while [[ "${extra}" ]]; do
		echo "${extra}" >> "${desktop}"
		extra=${1}; shift
	done

	(
		# wrap the env here so that the 'insinto' call
		# doesn't corrupt the env of the caller
		insinto /usr/share/applications
		doins "${desktop}"
	)
}

# Exported functions
rox_src_compile() {
	cd "${APPNAME}"
	#Some packages need to be compiled.
	chmod 755 AppRun
	if [[ -d src/ ]]; then
		# Bug 150303: Check with Rox-Clib will fail if the user has 0install
		# installed on their system somewhere, so remove the check for it in the
		# configure script, and adjust the path that the 'libdir' program uses
		# to search for it:
		if [[ -f src/configure.in ]]; then
			cd src
			sed -i.bak -e 's/ROX_CLIB_0LAUNCH/ROX_CLIB/' configure.in
			# TODO: This should really be 'eautoreconf', but that breaks a number
			# of packages (such as pager-1.0.1)
			eautoconf
			cd ..
		fi
		export LIBDIRPATH="${LIBDIR}"

		# Most rox self-compiles have a 'read' call to wait for the user to
		# press return if the compile fails.
		# Find and remove this:
		sed -i.bak -e 's/\<read\>/#read/' AppRun

		./AppRun --compile || die "Failed to compile the package"
		if [[ -n "${KEEP_SRC}" ]]; then
			cd src
			make clean
			cd ..
		else
			rm -rf src
		fi
		if [[ -d build ]]; then
			rm -rf build
		fi

		# Restore the original AppRun
		mv AppRun.bak AppRun
	fi
}

rox_src_install() {
	if [[ -d "${APPNAME}/Help/" ]]; then
		for i in "${APPNAME}"/Help/*; do
			dodoc "${i}"
		done
	fi

	insinto ${APPDIR}

	# Use 'cp -pPR' and not 'doins -r' here so we don't have to do a flurry of
	# 'chmod' calls on the executables in the appdir - Just be sure that all the
	# files in the original appdir prior to this step are correct, as they will
	# all be preserved.
	cp -pPR ${APPNAME} ${ED}${APPDIR}/${APPNAME}

	#create a script in bin to run the application from command line
	dodir /usr/bin/
	cat >"${ED}/usr/bin/${WRAPPERNAME}" <<EOF
#!/bin/sh
if [[ "\${LIBDIRPATH}" ]]; then
	export LIBDIRPATH="\${LIBDIRPATH}:${LIBDIR}"
else
	export LIBDIRPATH="${LIBDIR}"
fi

if [[ "\${APPDIRPATH}" ]]; then
	export APPDIRPATH="\${APPDIRPATH}:${APPDIR}"
else
	export APPDIRPATH="${APPDIR}"
fi
exec "${APPDIR}/${APPNAME}/AppRun" "\$@"
EOF
	chmod 755 "${ED}/usr/bin/${WRAPPERNAME}"

	# Old name of cmdline wrapper: /usr/bin/${APPNAME}
	if [[ ! "${APPNAME_COLLISION}" ]]; then
		ln -s ${WRAPPERNAME} ${ED}/usr/bin/${APPNAME}
		# TODO: Migrate this away... eventually
	else
		ewarn "The wrapper script /usr/bin/${APPNAME} has been removed"
		ewarn "due to a name collision.  You must run ${APPNAME} as"
		ewarn "/usr/bin/${WRAPPERNAME} instead."
	fi

	# Create a .desktop file if the proper category is supplied
	if [[ -n "${APPCATEGORY}" ]]; then
		# Copy the .DirIcon into /usr/share/pixmaps with the proper extension
		if [[ -f "${APPNAME}/.DirIcon" ]]; then
			local APPDIRICON=${APPNAME}/.DirIcon
			case "$(file -b ${APPDIRICON})" in
				"PNG image data"*)
					export APPICON=${WRAPPERNAME}.png
					;;
				"XML 1.0 document text"*)
					export APPICON=${WRAPPERNAME}.svg
					;;
				"X pixmap image text"*)
					export APPICON=${WRAPPERNAME}.xpm
					;;
				"symbolic link"*)
					APPDIRICON=$(dirname ${APPDIRICON})/$(readlink ${APPDIRICON})
					export APPICON=${WRAPPERNAME}.${APPDIRICON##*.}
					;;
				*)
					# Unknown... Remark on it, and just copy without an extension
					ewarn "Could not detect the file type of the application icon,"
					ewarn "copying without an extension."
					export APPICON=${WRAPPERNAME}
					;;
			esac
			insinto /usr/share/pixmaps
			newins "${APPDIRICON}" "${APPICON}"
		fi

		rox_desktop_entry "${WRAPPERNAME}" "${APPNAME}" "${APPICON}" "${APPCATEGORY}"
	fi

	#now compile any and all python files
	python_mod_optimize "${ED}${APPDIR}/${APPNAME}" >/dev/null 2>&1
}

rox_pkg_postinst() {
	einfo "${APPNAME} has been installed into ${APPDIR}"
	einfo "You can run it by typing ${WRAPPERNAME} at the command line."
	einfo "Or, you can run it by pointing the ROX file manager to the"
	einfo "install location -- ${APPDIR} -- and click"
	einfo "on ${APPNAME}'s icon, drag it to a panel, desktop, etc."
}

EXPORT_FUNCTIONS src_compile src_install pkg_postinst
