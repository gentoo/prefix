# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gnome2.eclass,v 1.73 2006/08/03 17:04:47 foser Exp $

# GNOME 2 ECLASS
inherit libtool gnome.org debug fdo-mime eutils

# Extra configure opts passed to econf
G2CONF=${G2CONF:=""}

# Extra options passed to elibtoolize
ELTCONF=${ELTCONF:=""}

# Should we use EINSTALL instead of DESTDIR
USE_EINSTALL=${USE_EINSTALL:=""}

# Run scrollkeeper for this package?
SCROLLKEEPER_UPDATE=${SCROLLKEEPER_UPDATE:="1"}

# Where to put scrollkeeper data lives
SCROLLKEEPER_DIR=${SCROLLKEEPER_DIR:="/var/lib/scrollkeeper"}

# Path to scrollkeeper-update
SCROLLKEEPER_UPDATE_BIN=${SCROLLKEEPER_UPDATE_BIN:="${ROOT}/usr/bin/scrollkeeper-update"}

# Path to gconftool-2
GCONFTOOL_BIN=${GCONFTOOL_BIN:="${ROOT}/usr/bin/gconftool-2"}

if [[ ${GCONF_DEBUG} != "no" ]]; then
	IUSE="debug"
fi

DEPEND=">=sys-apps/sed-4"

gnome2_src_unpack() {
	unpack ${A}
	cd ${S}

	# Prevent scrollkeeper access violations
	gnome2_omf_fix
}

gnome2_src_configure() {
	# Update the GNOME configuration options
	if [[ ${GCONF_DEBUG} != 'no' ]] ; then
		if use debug ; then
			G2CONF="${G2CONF} --enable-debug=yes"
		fi
	fi
	G2CONF="${G2CONF} $(use_enable doc gtk-doc)"

	# Run libtoolize
	elibtoolize ${ELTCONF}

	# Do not remove the addwrite. bug #128289
	addwrite "${ROOT}/root/.gnome2"

	# GST_REGISTRY is to work around gst-inspect trying to read/write /root
	GST_REGISTRY="${S}/registry.xml" econf "$@" ${G2CONF} || die "configure failed"
}

gnome2_src_compile() {
	gnome2_src_configure "$@"
	emake || die "compile failure"
}

gnome2_src_install() {
	# if this is not present, scrollkeeper-update may segfault and
	# create bogus directories in /var/lib/
	dodir "${SCROLLKEEPER_DIR}"

	# we must delay gconf schema installation due to sandbox
	export GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL="1"

	debug-print "You are testing with DESTDIR by default - AllanonJL"
	if [[ -z "${USE_EINSTALL}" || "${USE_EINSTALL}" = "0" ]]; then
		make DESTDIR=${EDEST} "scrollkeeper_localstate_dir=${D}${SCROLLKEEPER_DIR} " "$@" install || die "install failed"
	else
		einstall "scrollkeeper_localstate_dir=${D}${SCROLLKEEPER_DIR} " "$@" || die "einstall failed"
	fi

	unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL

	# Manual document installation
	[[ -n "${DOCS}" ]] && dodoc ${DOCS}

	# Do not keep /var/lib/scrollkeeper because:
	# 1. scrollkeeper will get regenerated at pkg_postinst()
	# 2. ${D}/var/lib/scrollkeeper contains only indexes for the current pkg
	#    thus it makes no sense if pkg_postinst ISN'T run for some reason.

	if [[ -z "$(find ${D} -name '*.omf')" ]]; then
		export SCROLLKEEPER_UPDATE="0"
	fi

	# Regenerate these in pkg_postinst()
	rm -rf "${D}${SCROLLKEEPER_DIR}"

	# Make sure this one doesn't get in the portage db
	rm -fr "${D}/usr/share/applications/mimeinfo.cache"
}


gnome2_gconf_install() {

	if [[ -x ${GCONFTOOL_BIN} ]]; then
		# We are ready to install the GCONF Scheme now
		unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL
		export GCONF_CONFIG_SOURCE=$(${GCONFTOOL_BIN} --get-default-source)

		einfo "Installing GNOME 2 GConf schemas"

		local contents="${ROOT}/var/db/pkg/*/${PN}-${PVR}/CONTENTS"

		for F in $(grep "obj /etc/gconf/schemas" ${contents} | sed 's:obj \([^ ]*\) .*:\1:' ); do
			if [[ -e "${F}" ]]; then
				# echo "DEBUG::gconf install  ${F}"
				${GCONFTOOL_BIN} --makefile-install-rule ${F} 1>/dev/null
			fi
		done

		# have gconf reload the new schemas
		ebegin "Reloading GConf schemas"
		killall -HUP gconfd-2
		eend $?
	fi

}

gnome2_gconf_uninstall() {
	if [[ -x ${GCONFTOOL_BIN} ]]; then
		unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL
		export GCONF_CONFIG_SOURCE=$(${GCONFTOOL_BIN} --get-default-source)

		einfo "Uninstalling GNOME 2 GConf schemas"

		local contents="${ROOT}/var/db/pkg/*/${PN}-${PVR}/CONTENTS"

		for F in $(grep "obj /etc/gconf/schemas" ${contents} | sed 's:obj \([^ ]*\) .*:\1:' ); do
			# echo "DEBUG::gconf install  ${F}"
			${GCONFTOOL_BIN} --makefile-uninstall-rule ${F} 1>/dev/null
		done
	fi
}

gnome2_icon_cache_update() {
	local updater=$(type -p gtk-update-icon-cache 2> /dev/null)

	ebegin "Updating icons cache"

	if [[ ! -x ${updater} ]] ; then
		debug-print "${updater} is not executable"

		# We failed to run
		eend 1

		return
	fi

	if ! grep -q "obj /usr/share/icons" ${ROOT}/var/db/pkg/*/${PF}/CONTENTS
	then
		debug-print "No items to update"

		# We are done successfully
		eend 0

		return
	fi

	local retval=0
	local fails=( )

	for dir in $(find ${ROOT}/usr/share/icons -maxdepth 1 -mindepth 1 -type d)
	do
		if [[ -f "${dir}/index.theme" ]] ; then
			local rv=0

			${updater} -qf ${dir}
			rv=$?

			if [[ ! $rv -eq 0 ]] ; then
				debug-print "Updating cache failed on ${dir}"

				# Add to the list of failures
				fails[$(( ${#fails[@]} + 1 ))]=$dir

				retval=2
			fi
		fi
	done

	eend ${retval}

	for (( i = 0 ; i < ${#fails[@]} ; i++ )) ; do
		### HACK!! This is needed until bash 3.1 is unmasked.
		## The current stable version of bash lists the sizeof fails to be 1
		## when there are no elements in the list because it is declared local.
		## In order to prevent the declaration from being in global scope, we
		## this hack to prevent an empty error message being printed for stable
		## users. -- compnerd && allanonjl
		if [[ "${fails[i]}" != "" && "${fails[i]}" != "()" ]] ; then
			eerror "Failed to update cache with icon ${fails[i]}"
		fi
	done
}

gnome2_omf_fix() {
	# workaround/patch against omf.make or omf-install/Makefile.in
	# in order to remove redundant scrollkeeper-updates.
	# - <liquidx@gentoo.org>

	local omf_makefiles filename

	omf_makefiles="$@"

	if [[ -f ${S}/omf-install/Makefile.in ]] ; then
		omf_makefiles="${omf_makefiles} ${S}/omf-install/Makefile.in"
	fi

	# FIXME: does this really work? because omf.make only gets included
	#        when autoconf/automake is run. You should directly patch
	#        the Makefile.in's

	if [[ -f ${S}/omf.make ]] ; then
		omf_makefiles="${omf_makefiles} ${S}/omf.make"
	fi

	# testing fixing of all makefiles found
	for filename in $(find ./ -name "Makefile.in" -o -name "Makefile.am") ; do
		omf_makefiles="${omf_makefiles} ${filename}"
	done

	ebegin "Fixing OMF Makefiles"

	local retval=0
	local fails=( )

	for omf in ${omf_makefiles} ; do
		local rv=0

		sed -i -e 's:scrollkeeper-update:true:' ${omf}
		retval=$?

		if [[ ! $rv -eq 0 ]] ; then
			debug-print "updating of ${omf} failed"

			# Add to the list of failures
			fails[$(( ${#fails[@]} + 1 ))]=$omf

			retval=2
		fi
	done

	eend $retval

	for (( i = 0 ; i < ${#fails[@]} ; i++ )) ; do
		### HACK!! This is needed until bash 3.1 is unmasked.
		## The current stable version of bash lists the sizeof fails to be 1
		## when there are no elements in the list because it is declared local.
		## In order to prevent the declaration from being in global scope, we
		## this hack to prevent an empty error message being printed for stable
		## users. -- compnerd && allanonjl
		if [[ "${fails[i]}" != "" && "${fails[i]}" != "()" ]] ; then
			eerror "Failed to update OMF Makefile ${fails[i]}"
		fi
	done
}

gnome2_scrollkeeper_update() {
	if [[ -x ${SCROLLKEEPER_UPDATE_BIN} && "${SCROLLKEEPER_UPDATE}" = "1" ]]
	then
		einfo "Updating scrollkeeper database ..."
		${SCROLLKEEPER_UPDATE_BIN} -q -p ${ROOT}${SCROLLKEEPER_DIR}
	fi
}

gnome2_pkg_postinst() {
	gnome2_gconf_install
	gnome2_scrollkeeper_update
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

#gnome2_pkg_prerm() {
#	gnome2_gconf_uninstall
#}

gnome2_pkg_postrm() {
	gnome2_scrollkeeper_update
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

EXPORT_FUNCTIONS src_unpack src_compile src_install pkg_postinst pkg_postrm
