# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/mico/mico-2.3.13.ebuild,v 1.4 2009/04/16 20:25:03 haubi Exp $

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="A freely available and fully compliant implementation of the CORBA standard"
HOMEPAGE="http://www.mico.org/"
SRC_URI="http://www.mico.org/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="gtk postgres qt3 ssl tcl threads X"

# doesn't compile:
#   bluetooth? ( net-wireless/bluez-libs )

RDEPEND="
	gtk?       ( >=x11-libs/gtk+-2 )
	postgres?  ( dev-db/postgresql )
	qt3?       ( =x11-libs/qt-3* )
	ssl?       ( dev-libs/openssl )
	tcl?       ( dev-lang/tcl )
	X?         ( x11-libs/libXt )
"
DEPEND="${RDEPEND}
	>=sys-devel/flex-2.5.2
	>=sys-devel/bison-1.22
"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}" || die "failed to cd to '${S}'"

	epatch "${FILESDIR}"/${P}-nolibcheck.patch
	epatch "${FILESDIR}"/${P}-gcc43.patch
	epatch "${FILESDIR}"/${P}-pthread.patch
	epatch "${FILESDIR}"/${P}-aix.patch

	# cannot use big TOC (AIX only), gdb doesn't like it.
	# This assumes that the compiler (or -wrapper) uses
	# gcc flag '-mminimal-toc' for compilation.
	sed -i -e 's/,-bbigtoc//' "${S}"/configure
}

src_compile() {
	tc-export CC CXX

	if use gtk; then
		# set up gtk-1 wrapper for gtk-2
		mkdir "${T}"/path || die "failed to create temporary path"
		cp "${FILESDIR}"/gtk-config "${T}"/path || die "failed to dupe gtk-config"
		chmod +x "${T}"/path/gtk-config || die "failed to arm gtk-config"
		export PATH="${T}"/path:${PATH}
	fi

	# Don't know which version of JavaCUP would suffice, but there is no
	# configure argument to disable checking for JavaCUP.
	# So we override the configure check to not find 'javac'.
	export ac_cv_path_JAVAC=no

	# '--without-ssl' just does not add another search path - the only way
	# to disable openssl utilization seems to override the configure check.
	use ssl || export ac_cv_lib_ssl_open=no

	# '--without-*' or '--with-*=no' does not disable some features, the value
	# needs to be empty instead. This applies to: bluetooth, gtk, pgsql, qt, tcl.
	# But --without-x works.

	# moc is searched within PATH, not within QTDIR.
	use qt3 && export MOC="${QTDIR}"/bin/moc

	# bluetooth and wireless both don't compile cleanly
	econf \
		--disable-mini-stl \
		$(use_enable threads) \
		--with-gtk=$(use gtk && echo /usr) \
		--with-pgsql=$(use postgres && echo /usr) \
		--with-qt=$(use qt3 && echo "${QTDIR}") \
		--with-tcl=$(use tcl && echo /usr) \
		$(use_with X x /usr) \
		--with-bluetooth='' \
		--disable-wireless

	emake || die "make failed"
}

src_install() {
	emake INSTDIR="${ED}"/usr SHARED_INSTDIR="${ED}"/usr install LDCONFIG=: || die "install failed"

	dodir /usr/share || die
	mv "${ED}"/usr/man "${ED}"/usr/share || die
	dodir /usr/share/doc/${PF} || die
	mv "${ED}"/usr/doc "${ED}"/usr/share/doc/${PF} || die

	dodoc BUGS CHANGES* CONVERT FAQ README* ROADMAP TODO VERSION WTODO || die
}
