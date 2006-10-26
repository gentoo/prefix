# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/timezone-data/timezone-data-2006k.ebuild,v 1.1 2006/08/28 22:59:36 vapier Exp $

EAPI="prefix"

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="Timezone data (/usr/share/zoneinfo) and utilities (tzselect/zic/zdump)"
HOMEPAGE="ftp://elsie.nci.nih.gov/pub/"
SRC_URI="ftp://elsie.nci.nih.gov/pub/tzdata${PV}.tar.gz
	ftp://elsie.nci.nih.gov/pub/tzcode${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="elibc_FreeBSD"

DEPEND=""

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${PN}-2005n-makefile.patch
	tc-is-cross-compiler && cp -pR ${S} ${S}-native
}

src_compile() {
	tc-export CC
	# Fixes bug #138251.
	use elibc_FreeBSD && append-flags -DSTD_INSPIRED
	emake || die "emake failed"
}

src_install() {
	local zic=""
	if tc-is-cross-compiler; then
		make -C ${S}-native CC=$(tc-getBUILD_CC) zic || die
		zic="zic=${S}-native/zic"
	fi
	make install ${zic} DESTDIR="${D}${EPREFIX}" || die
	rm -rf "${ED}"/usr/share/zoneinfo-leaps
	dodoc README Theory
	dohtml *.htm *.jpg
}

pkg_postinst() {
	if [[ ! -e ${EROOT}/etc/localtime ]] ; then
		ewarn "Please remember to set your timezone using the zic command."
		rm -f "${EROOT}"/etc/localtime
		ln -s ../usr/share/zoneinfo/Factory "${EROOT}"/etc/localtime
	fi
}
