# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/preload/preload-0.6.4-r1.ebuild,v 1.2 2010/03/29 15:40:17 pacho Exp $

inherit eutils autotools prefix

DESCRIPTION="Adaptive readahead daemon."
HOMEPAGE="http://sourceforge.net/projects/preload/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="vanilla"

WANT_AUTOCONF="2.56"

RDEPEND=">=dev-libs/glib-2.6"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/00-patch-configure.diff
	epatch "${FILESDIR}"/02-patch-preload_conf.diff
	epatch "${FILESDIR}"/02-patch-preload_sysconfig.diff
	use vanilla || epatch "${FILESDIR}"/000{1,2,3}-*.patch
	cat "${FILESDIR}"/preload-0.6.4.init.in > preload.init.in || die

	# Prefix patch
	epatch "${FILESDIR}/${PN}-0.6.3-prefix.patch"
	eprefixify src/preload.conf.in

	eautoreconf
}

src_compile() {
	econf --localstatedir="${EPREFIX}/var"
	emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	# Remove log and state file from image or they will be
	# truncated during merge
	rm "${ED}"/var/lib/preload/preload.state || die "cleanup failed"
	rm "${ED}"/var/log/preload.log || die "cleanup failed"
	keepdir /var/lib/preload
	keepdir /var/log
	newinitd "${FILESDIR}/init.d-preload" preload || die "initd failed"
	newconfd "${FILESDIR}/conf.d-preload" preload || die "confd failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}

pkg_postinst() {
	if ! use prefix; then
	einfo "You probably want to add preload to the boot runlevel like so:"
	einfo "# rc-update add preload boot"
	echo
	eerror "IMPORTANT: If you are upgrading from preload < 0.6 ensure to"
	eerror "merge your config files (etc-update) or system performance"
	eerror "may suffer."
	echo
	else
		elog "In prefix, you will have to start preload on the command line"
	fi	
}
