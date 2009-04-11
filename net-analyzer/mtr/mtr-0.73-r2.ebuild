# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/mtr/mtr-0.73-r2.ebuild,v 1.8 2008/11/09 12:15:15 vapier Exp $

inherit flag-o-matic autotools eutils

DESCRIPTION="My TraceRoute. Excellent network diagnostic tool."
HOMEPAGE="http://www.bitwizard.nl/mtr/"
SRC_URI="ftp://ftp.bitwizard.nl/mtr/${P}.tar.gz
		mirror://gentoo/gtk-2.0-for-mtr.m4.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="gtk ipv6"

RDEPEND="sys-libs/ncurses
	gtk? ( >=x11-libs/gtk+-2 )"
DEPEND="${RDEPEND}
	gtk? ( dev-util/pkgconfig )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	mv "${WORKDIR}"/gtk-2.0-for-mtr.m4 gtk-2.0.m4
	epatch "${FILESDIR}"/${P}-am_path_gtk.patch
	epatch "${FILESDIR}"/${P}-CVE-2008-2357.patch
	AT_M4DIR="." eautoreconf
}

src_compile() {
	local myconf
	use gtk || myconf="${myconf} --without-gtk"

	[[ ${CHOST} == *-darwin* ]] && append-flags "-DBIND_8_COMPAT"

	econf ${myconf} \
		$(use_enable gtk gtk2) \
		$(use_enable ipv6) \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	# this binary is universal. ie: it does both console and gtk.
	emake DESTDIR="${D}" install || die "make install failed"

	insinto /usr/share/${PN}
	doins img/mtr_icon.xpm

	if use !prefix ; then
		fowners root:0 /usr/sbin/mtr
		fperms 4710 /usr/sbin/mtr
	else
		# if we're non-privileged (assumption here, not a valid one though)
		# we should make sure it's not suid, such that privileged users can
		# run the binary (even though in use-case this is a bit limited)
		fperms 0711 /usr/sbin/mtr
	fi

	dodoc AUTHORS ChangeLog FORMATS NEWS README SECURITY TODO
}
