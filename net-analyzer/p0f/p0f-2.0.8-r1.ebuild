# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/p0f/p0f-2.0.8-r1.ebuild,v 1.7 2008/02/06 20:56:23 grobian Exp $

inherit eutils toolchain-funcs

DESCRIPTION="p0f performs passive OS detection based on SYN packets."
HOMEPAGE="http://lcamtuf.coredump.cx/p0f.shtml"
SRC_URI="http://lcamtuf.coredump.cx/p0f/${P}.tgz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="static"

DEPEND="net-libs/libpcap"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A} && cd ${S}
	sed -i 's;#include <net/bpf.h>;;' p0f.c || die "sed p0f.c failed"
	sed -i -e 's|^\(all: $(FILE)\).*$|\1|' \
		-e "s|^\(CFLAGS.*=\).*$|\1${CFLAGS}|" mk/* || die "sed makefiles failed"
}

src_compile() {
	local static
	use static && static="static"
	emake CC="$(tc-getCC)" ${static} || die "emake ${static} failed"
	emake CC="$(tc-getCC)" ${static} p0fq || die "emake ${static} p0fq failed"
}

src_install () {
	use static && mv p0f-static p0f
	dosbin p0f p0frep test/p0fq || die

	insinto /etc/p0f
	doins p0f.fp p0fa.fp p0fr.fp

	doman p0f.1 || die
	cd doc
	dodoc ChangeLog CREDITS KNOWN_BUGS README TODO

	newconfd "${FILESDIR}"/${PN}.confd ${PN} || die "newconfd failed"
	newinitd "${FILESDIR}"/${PN}.initd3 ${PN} || die "newinitd failed"
}

pkg_postinst(){
	elog "Adjust /etc/conf.d/p0f to your liking before using the"
	elog "init script. For more information on options, read man p0f."
}
