# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/preload/preload-0.6.4.ebuild,v 1.1 2009/05/07 03:06:49 darkside Exp $

inherit eutils prefix

DESCRIPTION="Adaptive readahead daemon."
HOMEPAGE="http://sourceforge.net/projects/preload"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="vanilla"

RDEPEND="dev-libs/glib"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	use vanilla || epatch "${FILESDIR}/${PN}-0.6.3-forking-children.patch"
	use vanilla || epatch "${FILESDIR}/${PN}-0.6.3-overlapping-io-bursts.patch"

	# Prefix patch
	epatch "${FILESDIR}/${PN}-0.6.3-prefix.patch"
	eprefixify src/preload.conf.in
}

src_compile() {
	econf --localstatedir="${EPREFIX}/var"
	emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	rm -rf "${ED}/etc/rc.d/" || die "rm rc.d failed"
	rm -rf "${ED}/etc/sysconfig/" || die "rm sysconfig failed"
	rm -f "${ED}/var/lib/preload/preload.state" || die "cleanup1 failed"
	rm -f "${ED}/var/log/preload.log" || die "cleanup2 failed"
	keepdir /var/lib/preload
	keepdir /var/log
	newinitd "${FILESDIR}/init.d-preload" preload || die "initd failed"
	newconfd "${FILESDIR}/conf.d-preload" preload || die "confd failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}

pkg_postinst() {
	if ! use prefix; then
		elog "To start preload at boot, remember to add it to a runlevel:"
		elog "# rc-update add preload default"
	else
		elog "In prefix, you will have to start preload on the command line"
	fi	
}
