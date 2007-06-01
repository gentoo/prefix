# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/guile/guile-1.8.1-r3.ebuild,v 1.4 2007/05/31 19:15:55 flameeyes Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="Scheme interpreter"
HOMEPAGE="http://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

DEPEND=">=dev-libs/gmp-4.1 >=sys-devel/libtool-1.5.6 sys-devel/gettext"

# Guile seems to contain some slotting support, /usr/share/guile/ is slotted,
# but there are lots of collisions. Most in /usr/share/libguile. Therefore
# I'm slotting this in the same slot as guile-1.6* for now.
SLOT="12"
MAJOR="1.8"

IUSE="networking regex discouraged deprecated elisp nls debug-freelist debug-malloc debug threads"

src_unpack() {
	unpack ${A}
	cd ${S}

	# for xbindkeys
	cp "${EPREFIX}"/usr/share/gettext/config.rpath .
	epatch ${FILESDIR}/guile-1.8.1-autotools_fixes.patch
	epatch "${FILESDIR}"/guile-1.8.1-echo-n.patch

	# for free-bsd, bug 179728
	epatch $FILESDIR/guile-1.8.1-defaultincludes.patch
	epatch $FILESDIR/guile-1.8.1-clog-cexp.patch

	eautoreconf

	# for lilypond 2.11.x
	epatch ${FILESDIR}/guile-1.8-rational.patch
}


src_compile() {
#will fail for me if posix is disabled or without modules -- hkBst
	econf \
		--disable-error-on-warning \
		--disable-static \
		--enable-posix \
		$(use_enable networking) \
		$(use_enable regex) \
		$(use deprecated || use_enable discouraged) \
		$(use_enable deprecated) \
		$(use_enable elisp) \
		$(use_enable nls) \
		--disable-rpath \
		$(use_enable debug-freelist) \
		$(use_enable debug-malloc) \
		$(use_enable debug guile-debug) \
		$(use_with threads) \
		--with-modules

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
