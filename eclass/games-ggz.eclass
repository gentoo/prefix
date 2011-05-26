# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/games-ggz.eclass,v 1.6 2011/04/19 21:19:11 scarabeus Exp $

inherit base

# For GGZ Gaming Zone packages

GAMES_GGZ_EXPF="src_compile src_install pkg_postinst pkg_postrm"
case "${EAPI:-0}" in
	2|3|4) GAMES_GGZ_EXPF+=" src_configure" ;;
	0|1) : ;;
	*) die "EAPI=${EAPI} is not supported" ;;
esac
EXPORT_FUNCTIONS ${GAMES_GGZ_EXPF}

HOMEPAGE="http://www.ggzgamingzone.org/"
SRC_URI="mirror://ggz/${PV}/${P}.tar.gz"

GGZ_MODDIR="/usr/share/ggz/modules"

games-ggz_src_configure() {
	econf \
		--disable-dependency-tracking \
		--enable-noregistry="${EPREFIX}${GGZ_MODDIR}" \
		$(has debug ${IUSE} && ! use debug && echo --disable-debug) \
		"$@"
}

games-ggz_src_compile() {
	has src_configure ${GAMES_GGZ_EXPF} || games-ggz_src_configure
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
	[[ ${EBUILD_PHASE} == "postinst" || ${EBUILD_PHASE} == "postrm" ]] \
	 	 || die "${FUNCNAME} can only be used in pkg_postinst or pkg_postrm"

	# ggz-config needs libggz, so it could be broken
	ggz-config -h &> /dev/null || return 1

	local confdir=${EROOT}/etc
	local moddir=${EROOT}/${GGZ_MODDIR}
	local dsc rval=0

	mkdir -p "${confdir}"
	echo -n > "${confdir}"/ggz.modules
	if [[ -d ${moddir} ]] ; then
		ebegin "Installing GGZ modules"
		cd "${moddir}"
		find . -type f -name '*.dsc' | while read dsc ; do
			DESTDIR=${ROOT} ggz-config -Dim "${dsc}" || ((rval++))
		done
		eend ${rval}
	fi
	return ${rval}
}

# Register new modules
games-ggz_pkg_postinst() {
	games-ggz_update_modules
}

# Unregister old modules
games-ggz_pkg_postrm() {
	games-ggz_update_modules
}
