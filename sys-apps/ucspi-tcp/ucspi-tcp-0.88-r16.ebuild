# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/ucspi-tcp/ucspi-tcp-0.88-r16.ebuild,v 1.2 2007/02/18 21:07:18 grobian Exp $

EAPI="prefix"

inherit eutils toolchain-funcs fixheadtails flag-o-matic

DESCRIPTION="Collection of tools for managing UNIX services"
HOMEPAGE="http://cr.yp.to/ucspi-tcp.html"
SRC_URI="
	http://cr.yp.to/${PN}/${P}.tar.gz
	mirror://qmail/ucspi-rss.diff
"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="selinux doc"
RESTRICT="test"

DEPEND=""
RDEPEND="${DEPEND}
	doc? ( app-doc/ucspi-tcp-man )
	selinux? ( sec-policy/selinux-ucspi-tcp )"
PROVIDE="virtual/inetd"

src_unpack() {
	unpack "${P}.tar.gz"
	cd "${S}"

	epatch \
		"${FILESDIR}"/${PV}-errno.patch \
		"${DISTDIR}"/ucspi-rss.diff \
		"${FILESDIR}"/${PV}-rblsmtpd-ignore-on-RELAYCLIENT.patch

	ht_fix_file Makefile

	# gcc-3.4.5 and other several versions contain a bug on some platforms that
	# cause this error:
	# tcpserver: fatal: temporarily unable to figure out IP address for 0.0.0.0: file does not exist
	# To work around this, we use -O1 here instead.
	replace-flags -O? -O1

	echo "$(tc-getCC) ${CFLAGS}" > conf-cc
	echo "$(tc-getCC) ${LDFLAGS}" > conf-ld
	echo "/usr/" > conf-home

	# allow larger responses
	sed -i 's|if (text.len > 200) text.len = 200;|if (text.len > 500) text.len = 500;|g' \
		"${S}/rblsmtpd.c"

	if [[ -n "${UCSPI_TCP_PATCH_DIR}" && -d "${UCSPI_TCP_PATCH_DIR}" ]]
	then
		echo
		ewarn "You enabled custom patches from ${UCSPI_TCP_PATCH_DIR}."
		ewarn "Be warned that you won't get any support when using "
		ewarn "this feature. You're on your own from now!"
		echo
		ebeep
		epatch "${UCSPI_TCP_PATCH_DIR}/"*
	fi
}

src_compile() {
	emake || die
}

src_install() {
	dobin tcpserver tcprules tcprulescheck argv0 recordio tcpclient *\@ \
		tcpcat mconnect mconnect-io addcr delcr fixcrio rblsmtpd || die
	doman *.[15]
	dodoc CHANGES FILES README SYSDEPS TARGETS TODO VERSION
	dodoc README.tcpserver-limits-patch
	insinto /etc/tcprules.d/
	newins "${FILESDIR}"/tcprules-Makefile Makefile
}

pkg_postinst() {
	einfo "We have started a move to get all tcprules files into"
	einfo "/etc/tcprules.d/, where we have provided a Makefile to"
	einfo "easily update the CDB file."
}
