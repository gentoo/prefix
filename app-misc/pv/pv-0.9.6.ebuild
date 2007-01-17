# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pv/pv-0.9.6.ebuild,v 1.4 2006/09/16 14:02:23 dertobi123 Exp $

EAPI="prefix"

DESCRIPTION="Pipe Viewer: a tool for monitoring the progress of data through a pipe"
HOMEPAGE="http://www.ivarch.com/programs/pv.shtml"
SRC_URI="mirror://sourceforge/pipeviewer/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND="virtual/libc"

src_install() {
	make DESTDIR=${D} UNINSTALL="${EPREFIX}"/bin/true install || die "install failed"
}
