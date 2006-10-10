# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gnome2.eclass,v 1.62 2005/09/08 17:19:22 leonardop Exp $
#
# Authors:
# Bruce A. Locke <blocke@shivan.org>
# Spidler <spider@gentoo.org>

inherit libtool gnome.org debug fdo-mime

# Gnome 2 ECLASS

# extra configure opts passed to econf
[ -z "$G2CONF" ] && G2CONF=""

# extra options passed to elibtoolize
[ -z "$ELTCONF" ] && ELTCONF=""

# whether to run scrollkeeper for this package
[ -z "$SCROLLKEEPER_UPDATE" ] && SCROLLKEEPER_UPDATE="1"

# use make DESTDIR=${D} install rather than einstall
[ -z "$USE_DESTDIR" ] && USE_DESTDIR=""


IUSE="debug"


DEPEND=">=sys-apps/sed-4"

gnome2_src_configure() {

	# [ -n "${ELTCONF}" ] && elibtoolize ${ELTCONF}
	elibtoolize ${ELTCONF}

	use debug && G2CONF="${G2CONF} --enable-debug=yes"

	# doc keyword for gtk-doc
	G2CONF="${G2CONF} $(use_enable doc gtk-doc)"

	econf "$@" ${G2CONF} || die "./configure failure"

}

gnome2_src_compile() {

	gnome2_src_configure "$@"
	emake || die "compile failure"

}

gnome2_src_install() {

	# if this is not present, scrollkeeper-update may segfault and
	# create bogus directories in /var/lib/
	dodir /var/lib/scrollkeeper

	# we must delay gconf schema installation due to sandbox
	export GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL="1"

	if [ -z "${USE_DESTDIR}" -o "${USE_DESTDIR}" = "0" ]; then
		einstall "scrollkeeper_localstate_dir=${D}/var/lib/scrollkeeper/" "$@" || die "einstall failed"
	else
		make DESTDIR=${EDEST} \
		   	"$@" install || die "make DESTDIR install failed"
	fi

	unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL

	# manual document installation
	[ -n "${DOCS}" ] && dodoc ${DOCS}

	# do not keep /var/lib/scrollkeeper because:
	# 1. scrollkeeper will get regenerated at pkg_postinst()
	# 2. ${D}/var/lib/scrollkeeper contains only indexes for the current pkg
	#    thus it makes no sense if pkg_postinst ISN'T run for some reason.

	if [ -z "`find ${D} -name '*.omf'`" ]; then
		export SCROLLKEEPER_UPDATE="0"
	fi

	# regenerate these in pkg_postinst()
	rm -rf ${D}/var/lib/scrollkeeper
	# make sure this one doesn't get in the portage db
	rm -fr ${D}/usr/share/applications/mimeinfo.cache

}


gnome2_gconf_install() {

	if [ -x ${ROOT}/usr/bin/gconftool-2 ]
	then
		unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL
		export GCONF_CONFIG_SOURCE=`${ROOT}/usr/bin/gconftool-2 --get-default-source`
		einfo "Installing GNOME 2 GConf schemas"
		grep "obj /etc/gconf/schemas" ${ROOT}/var/db/pkg/*/${PF}/CONTENTS | sed 's:obj \([^ ]*\) .*:\1:' | while read F; do
			if [ -e "${F}" ]; then
				# echo "DEBUG::gconf install  ${F}"
				${ROOT}/usr/bin/gconftool-2  --makefile-install-rule ${F} 1>/dev/null
			fi
		done
	fi

}

gnome2_gconf_uninstall() {

	if [ -x ${ROOT}/usr/bin/gconftool-2 ]
	then
		unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL
		export GCONF_CONFIG_SOURCE=`${ROOT}/usr/bin/gconftool-2 --get-default-source`
		einfo "Uninstalling GNOME 2 GConf schemas"
		cat ${ROOT}/var/db/pkg/*/${PN}-${PVR}/CONTENTS | grep "obj /etc/gconf/schemas" | sed 's:obj \([^ ]*\) .*:\1:' |while read F; do
			# echo "DEBUG::gconf install  ${F}"
			${ROOT}/usr/bin/gconftool-2  --makefile-uninstall-rule ${F} 1>/dev/null
		done
	fi

}

gnome2_icon_cache_update() {
	local updater=`which gtk-update-icon-cache`
	if ! grep -q "obj /usr/share/icons" ${ROOT}/var/db/pkg/*/${PF}/CONTENTS \
	|| [ ! -x "$updater" ]; then
		# Nothing to update
		return
	fi

	ebegin "Updating icons cache"

	local retval=0
	for dir in \
	$(find ${ROOT}/usr/share/icons -maxdepth 1 -mindepth 1 -type d); do
		if [ -f "${dir}/index.theme" ]; then
			$updater -qf $dir || retval=$?
		fi
	done

	eend $retval
}

gnome2_omf_fix() {

	# workaround/patch against omf.make or omf-install/Makefile.in
	# in order to remove redundant scrollkeeper-updates.
	# - <liquidx@gentoo.org>

	local omf_makefiles

	omf_makefiles="$@"

	[ -f ${S}/omf-install/Makefile.in ] \
		&& omf_makefiles="${omf_makefiles} ${S}/omf-install/Makefile.in"

	# FIXME: does this really work? because omf.make only gets included
	#        when autoconf/automake is run. You should directly patch
	#        the Makefile.in's

	[ -f ${S}/omf.make ] \
		&& omf_makefiles="${omf_makefiles} ${S}/omf.make"

	ebegin "Fixing OMF Makefiles"
	local retval=0
	for omf in ${omf_makefiles}; do
		sed -i -e 's:scrollkeeper-update:true:' ${omf} || retval=$?
	done
	eend $retval

}

gnome2_scrollkeeper_update() {

	if [ -x ${ROOT}/usr/bin/scrollkeeper-update ] && [ "${SCROLLKEEPER_UPDATE}" = "1" ]
	then
		einfo "Updating scrollkeeper database ..."
		scrollkeeper-update -q -p ${ROOT}/var/lib/scrollkeeper
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

#EXPORT_FUNCTIONS src_compile src_install pkg_postinst pkg_prerm  pkg_postrm
EXPORT_FUNCTIONS src_compile src_install pkg_postinst pkg_postrm
