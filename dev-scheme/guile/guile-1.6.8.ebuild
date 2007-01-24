# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/guile/guile-1.6.8.ebuild,v 1.1 2007/01/12 14:45:43 hkbst Exp $

EAPI="prefix"

inherit flag-o-matic eutils libtool

DESCRIPTION="Scheme interpreter"
HOMEPAGE="http://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
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

src_compile() {
	use ppc && replace-flags -O3 -O2

	# Fix for bug 26484: This package fails to build when built with
	# -g3, at least on some architectures.  (19 Aug 2003 agriffis)
	filter-flags -g3

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

#	# install a symlink to slib; probably not worth it to test for slib use flag
#	dosym ${eroot}/usr/lib/slib/ ${eroot}/usr/share/guile/slib
}

# keeping this in slib for now
#pkg_postinst() {
#	if use slib; then
#		einfo "installing slib for guile..."
#		guile -c "(use-modules (ice-9 slib)) (require 'new-catalog)"
#	fi
#}
