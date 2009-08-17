# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils

DESCRIPTION="i6fork provides a fixed fork version for interix 6"
HOMEPAGE="http://dev.gentoo.org/~mduft/i6fork"
SRC_URI="${HOMEPAGE}/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="-* ~x86-interix"

pkg_setup() {
	if [[ ${CHOST} != *-interix6* ]]; then
		die "only interix 6 is supported by i6fork. other versions don't require this!"
	fi

	# i know, this one is hackish, but i have a big problem with re-installing:
	#  the library $EPREFIX/usr/lib/libi6fork.so is preloaded in _every_
	#  binary run from inside $EPREFIX (even non-prefix installed binaries!).
	#  this means that replacing the file while merging is not possible, since
	#  moving the file away for merging will make all executables unusable,
	#  that are required to move the new version in place.
	ewarn ""
	ewarn "${CATEGORY}/${PN} has known problems with re-installing itself."
	ewarn "to avoid such problems, ${CATEGORY}/${PN} will add itself to"
	ewarn "${EPREFIX}/etc/portage/package.mask (with full version, so"
	ewarn "upgrading when a new version becomes available is no problem)."
	ewarn ""
	
	# updaring is not of such a problem, since a new library with a different
	#  name will be installed. that library will be used after rebuilding bash
	#  and/or re-logging in into the system with a clean shell.
	#  WARNING: bash _has_ to be rebuilt before starting a new session.
	#           otherwise both the old, and the new version will be loaded,
	#           which could lead to problems (but should work normally).
	ewarn ""
	ewarn "if upgrading ${CATEGORY}/${PN} from a previous version, please"
	ewarn "make sure to run \"emerge @preserved-rebuild\" before starting"
	ewarn "a new session!"
	ewarn ""

	ewarn ""
	ewarn "to fully uninstall ${CATEGORY}/${PN}, you need to first mask"
	ewarn "the \"i6fork\" USE flag, re-build bash, uninstall ${CATEGORY}/${PN},"
	ewarn "and finally re-start all shells. The last remaining stray files"
	ewarn "will then be removed after the next emerge."
	ewarn ""
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-preload.patch
}

src_install() {
	emake DESTDIR="${D}" install

	echo "LD_PRELOAD='${EPREFIX}/usr/lib/libi6fork.so'" >> "${T}/00${PN}" || die
	doenvd "${T}/00${PN}" || die

	# hackish? :)
	echo "# Automatically masked to prevent re-install. See ${CATEGORY}/${PN} ebuild for details." >> "${EPREFIX}/etc/portage/package.mask"
	echo "=${CATEGORY}/${P}*" >> "${EPREFIX}/etc/portage/package.mask"
}

