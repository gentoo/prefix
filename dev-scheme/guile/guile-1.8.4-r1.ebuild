# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/guile/guile-1.8.4-r1.ebuild,v 1.2 2008/05/06 22:09:30 hkbst Exp $

inherit eutils autotools flag-o-matic

DESCRIPTION="Scheme interpreter"
HOMEPAGE="http://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.gz"

LICENSE="LGPL-2.1"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
RESTRICT="!regex? ( test )"

DEPEND=">=dev-libs/gmp-4.1 >=sys-devel/libtool-1.5.6 sys-devel/gettext"

# Guile seems to contain some slotting support, /usr/share/guile/ is slotted,
# but there are lots of collisions. Most in /usr/share/libguile. Therefore
# I'm slotting this in the same slot as guile-1.6* for now.
SLOT="12"
MAJOR="1.8"

IUSE="networking regex discouraged deprecated elisp nls debug-freelist debug-malloc debug threads"

src_unpack() {
	unpack ${A}; cd "${S}"

	epatch "${FILESDIR}"/${P}-interix.patch

	sed "s_sleep 999_sleep 1_" -i test-suite/tests/popen.test

	#bug 214787
	epatch "${FILESDIR}"/gcc-4.3.patch

	#echo -n doesn't work everywhere. top level configure.in made
	#it right anyway, only on guile-readline it was wrong.
	epatch "${FILESDIR}"/${P}-echo.patch

#	cp configure.in configure.in.old

	#for libtool-2.2*, bug 212723
	sed 's/AC_CONFIG_MACRO_DIR(\[m4\])/AC_CONFIG_MACRO_DIR(\[guile-config\])/' -i configure.in

#	diff -u configure.in.old configure.in

	eautoreconf
}


src_compile() {
	# see bug #178499
	filter-flags -ftree-vectorize

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
	echo "GUILE_LOAD_PATH=\"${EPREFIX}/usr/share/guile/${MAJOR}\"" > "${ED}"/etc/env.d/50guile

	# necessary for registering slib, see bug 206896
	keepdir /usr/share/guile/site
}

pkg_postinst() {
	[ "${ROOT}" == "/" ] && pkg_config
}

pkg_config() {
	if has_version dev-scheme/slib; then
		einfo "Registering slib with guile"
		install_slib_for_guile
	fi
}

_pkg_prerm() {
	rm -f "${EROOT}"/usr/share/guile/site/slibcat
}
