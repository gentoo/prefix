# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pv/pv-0.9.9.ebuild,v 1.3 2007/07/07 01:39:20 angelos Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Pipe Viewer: a tool for monitoring the progress of data through a pipe"
HOMEPAGE="http://www.ivarch.com/programs/pv.shtml"
SRC_URI="mirror://sourceforge/pipeviewer/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="nls"

DEPEND="virtual/libc"

src_compile() {
	econf $(use_enable nls) || die "configure failed"
	epatch "${FILESDIR}/pv-remove-doc-target.patch"
	emake || die "make failed"
}

src_install() {
	make DESTDIR=${D} UNINSTALL="${EPREFIX}"/bin/true install || die "install failed"
}
