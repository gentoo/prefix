# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/genlop/genlop-0.30.8.ebuild,v 1.1 2007/09/25 23:29:03 lavajoe Exp $

EAPI="prefix"

inherit bash-completion eutils

DESCRIPTION="A nice emerge.log parser"
HOMEPAGE="http://www.gentoo.org/proj/en/perl"
SRC_URI="mirror://gentoo//${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/perl-5.8.0-r12
	 >=dev-perl/DateManip-5.40
	 dev-perl/libwww-perl"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.30.7-prefix.patch
	eprefixify genlop
	[[ ${CHOST} == *-solaris* ]] && \
		sed -i -e 's/ps ax -o pid,args/ps -ef -o pid,args/' genlop
	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e 's/ps ax -o pid,args/ps ax -o pid,command/' genlop
}

src_install() {
	dobin genlop || die
	dodoc README Changelog
	doman genlop.1
	dobashcompletion genlop.bash-completion genlop
}
