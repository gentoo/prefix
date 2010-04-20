# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/mtr/mtr-0.75.ebuild,v 1.9 2009/12/28 20:55:15 maekke Exp $

EAPI="2"
inherit eutils autotools flag-o-matic

DESCRIPTION="My TraceRoute. Excellent network diagnostic tool."
HOMEPAGE="http://www.bitwizard.nl/mtr/"
SRC_URI="ftp://ftp.bitwizard.nl/mtr/${P}.tar.gz
		mirror://gentoo/gtk-2.0-for-mtr.m4.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="gtk ipv6"

RDEPEND="sys-libs/ncurses
	gtk? ( >=x11-libs/gtk+-2.4.0 )"
DEPEND="${RDEPEND}
	gtk? ( dev-util/pkgconfig )"

src_prepare() {
	epatch "${FILESDIR}/${P}--Wno-pointer-sign.patch"
	# Keep this comment and following move, even incase ebuild does not needs
	# it: kept gtk-2.0.m4 in SRC_URI but you'll have to mv it before autoreconf
	mv "${WORKDIR}"/gtk-2.0-for-mtr.m4 gtk-2.0.m4 #222909
	AT_M4DIR="." eautoreconf
}
src_configure() {
	# In the source's configure script -lresolv is commented out. Apparently it
	# is needed for 64bit macos still.
	use x64-macos && append-libs -lresolv
	econf \
		$(use_with gtk) \
		$(use_enable ipv6)
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	if use !prefix ; then
		fowners root:0 /usr/sbin/mtr
		fperms 4710 /usr/sbin/mtr
	else
		# if we're non-privileged (assumption here, not a valid one though)
		# we should make sure it's not suid, such that privileged users can
		# run the binary (even though in use-case this is a bit limited)
		fperms 0711 /usr/sbin/mtr
	fi

	dodoc AUTHORS ChangeLog FORMATS NEWS README SECURITY TODO || die
}
