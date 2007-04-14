# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/ppmd/ppmd-9.1_p10.ebuild,v 1.5 2007/04/11 05:21:59 jer Exp $

EAPI="prefix"

inherit eutils flag-o-matic

PATCHV="${P##*_p}"
MY_P="${P%%_*}"
MY_P="${MY_P/-/_}"
MY_S=${PN}-i1
S=${WORKDIR}/${MY_S}
DESCRIPTION="PPM based compressor -- better behaved than bzip2"
HOMEPAGE="http://http.us.debian.org/debian/pool/main/p/ppmd/"
SRC_URI="http://http.us.debian.org/debian/pool/main/p/ppmd/${MY_P}.orig.tar.gz
	http://http.us.debian.org/debian/pool/main/p/ppmd/${MY_P}-${PATCHV}.diff.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND=">=sys-apps/sed-4
	app-arch/gzip
	sys-devel/patch
	sys-devel/autoconf
	sys-devel/automake"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${WORKDIR}/${MY_P}-${PATCHV}.diff"
	epatch "${S}/${MY_P/_/-}/debian/patches"/*.patch
	mv "${S}/${MY_P/_/-}/Makefile" "${S}" || die "no makefile found"
	epatch "${FILESDIR}/${PN}-p${PATCHV}-makefile.patch"
}

src_compile() {
#	replace-flags "-O3" "-O2"
#	see bug #44529 if this starts producing goofy executables
#	if it pops up again, re-enable replace-flags.
	append-flags "-fno-inline-functions -fno-exceptions -fno-rtti"
	emake || die
}

src_install() {
	# package has no configure, so need prefix here
	make install DESTDIR="${D}${EPREFIX}" || die "failed installing"
	doman "${S}/${MY_P/_/-}/debian/PPMd.1" || die "failed installing manpage"
	dodoc "${S}/read_me.txt" || die "failed installed readme"
}
