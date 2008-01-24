# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/guile/guile-1.6.7.ebuild,v 1.1 2007/01/10 17:31:47 hkbst Exp $

EAPI="prefix"

inherit flag-o-matic eutils libtool

DESCRIPTION="Scheme interpreter"
HOMEPAGE="http://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

# Problems with parallel builds (#34029), so I'm taking the safer route
MAKEOPTS="${MAKEOPTS} -j1"

DEPEND=">=sys-libs/ncurses-5.1
	>=sys-libs/readline-4.1"

# NOTE: in README-PACKAGERS, guile recommends different versions be installed
#       in parallel. They're talking about LIBRARY MAJOR versions and not
#       the actual guile version that was used in the past.
#
#       So I'm slotting this as 12 beacuse of the library major version
SLOT="12"
MAJOR="1.6"

src_unpack() {
	unpack ${A}
	cd ${S}

	if [ "${ARCH}" = "amd64" ]; then
		epatch ${FILESDIR}/guile-amd64.patch
	fi

	if [ "${ARCH}" = "ppc" ]; then
		replace-flags -O3 -O2
	fi

	# fix for putenv on Darwin
	epatch ${FILESDIR}/${P}-posix.patch
	# fixes sleep/usleep errors on Darwin
	epatch ${FILESDIR}/${P}-scmsigs.patch
	# Fix for gcc-4.0
	epatch ${FILESDIR}/${P}-gcc4.patch
}

src_compile() {
	# Fix for bug 26484: This package fails to build when built with
	# -g3, at least on some architectures.  (19 Aug 2003 agriffis)
	filter-flags -g3

	[[ ${CHOST} == *-darwin* ]] && append-flags -Dmacosx

	econf \
		--with-threads \
		--with-modules \
		--enable-deprecation=no || die

	# Please keep --enable-deprecation=no in future bumps.
	# Danny van Dyk <kugelfang@gentoo.org 2004/09/19

	emake || die "make failed"
}

src_install() {
	einstall || die "install failed"
	dodoc AUTHORS ChangeLog GUILE-VERSION HACKING NEWS README SNAPSHOTS THANKS

	# texmacs needs this, closing bug #23493
	dodir /etc/env.d

	# We don't slot the env.d entry because /usr/bin/guile-config is
	# there anyway, and will only match the last guile installed.
	# so the GUILE_LOAD_PATH will match the data available from guile-config.
	echo "GUILE_LOAD_PATH=\"${EPREFIX}/usr/share/guile/${MAJOR}\"" > ${ED}/etc/env.d/50guile
}
