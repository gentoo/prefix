# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pv/pv-1.0.1.ebuild,v 1.1 2007/08/13 02:05:30 angelos Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Pipe Viewer: a tool for monitoring the progress of data through a pipe"
HOMEPAGE="http://www.ivarch.com/programs/pv.shtml"
SRC_URI="mirror://sourceforge/pipeviewer/${P}.tar.gz"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="debug nls"

DEPEND="virtual/libc"

src_compile() {
	econf \
		$(use_enable nls) \
		$(use_enable debug debugging) \
		|| die "configure failed"
	#epatch "${FILESDIR}/pv-remove-doc-target.patch"
	epatch "${FILESDIR}/${P}-inputisoutput.patch"
	emake || die "make failed"
}

src_install() {
	make DESTDIR=${D} UNINSTALL="${EPREFIX}"/bin/true install || die "install failed"
}
