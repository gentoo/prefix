# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pv/pv-1.1.0.ebuild,v 1.3 2007/10/01 18:45:53 fmccor Exp $

EAPI="prefix"

DESCRIPTION="Pipe Viewer: a tool for monitoring the progress of data through a pipe"
HOMEPAGE="http://www.ivarch.com/programs/pv.shtml"
SRC_URI="mirror://sourceforge/pipeviewer/${P}.tar.gz"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="debug nls"

src_compile() {
	econf \
		$(use_enable debug debugging) \
		$(use_enable nls) \
		|| die "configure failed"

	emake || die "make failed"
}

src_install() {
	make DESTDIR=${D} UNINSTALL="${EPREFIX}"/bin/true install || die "install failed"

	dodoc README doc/NEWS doc/TODO
}
