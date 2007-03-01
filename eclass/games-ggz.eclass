# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/games-ggz.eclass,v 1.1 2007/02/22 09:36:03 nyhm Exp $

# For GGZ Gaming Zone packages

EXPORT_FUNCTIONS src_compile src_install pkg_postinst pkg_postrm

HOMEPAGE="http://www.ggzgamingzone.org/"
SRC_URI="mirror://ggz/${PV}/${P}.tar.gz"

GGZ_MODDIR="/usr/share/ggz/modules"

# Output the configure option to disable "General Debugging"
games-ggz_debug() {
	if has debug ${IUSE} && ! use debug ; then
		echo --disable-debug
	fi
}

games-ggz_src_compile() {
	econf \
		--disable-dependency-tracking \
		--enable-noregistry="${GGZ_MODDIR}" \
		$(games-ggz_debug) \
		"$@" || die
	emake || die "emake failed"
}

games-ggz_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	local f
	for f in AUTHORS ChangeLog NEWS QuickStart.GGZ README* TODO ; do
		[[ -f ${f} ]] && dodoc ${f}
	done
}

# Update ggz.modules with the .dsc files from ${GGZ_MODDIR}.
games-ggz_update_modules() {
	[[ ${EBUILD_PHASE} == "postinst" ]] || [[ ${EBUILD_PHASE} == "postrm" ]] \
	 	 || die "${FUNCNAME} can only be used in pkg_postinst or pkg_postrm"

	type -p ggz-config > /dev/null || return 1
	local confdir=${ROOT}/etc
	local moddir=${ROOT}/${GGZ_MODDIR}
	local dsc rval=0

	mkdir -p "${confdir}"
	echo -n > "${confdir}"/ggz.modules
	if [[ -d ${moddir} ]] ; then
		ebegin "Installing GGZ modules"
		cd "${moddir}"
		for dsc in $(find . -type f -name '*.dsc') ; do
			debug-print ${dsc}
			DESTDIR=${ROOT} ggz-config -Dim ${dsc} || rval=1
		done
		eend ${rval}
	fi
	return ${rval}
}

# Register new modules
games-ggz_pkg_postinst() {
	has games ${INHERITED} && games_pkg_postinst
	games-ggz_update_modules
}

# Unregister old modules
games-ggz_pkg_postrm() {
	games-ggz_update_modules
}
