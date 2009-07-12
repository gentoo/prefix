# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-electronics/gtkwave/gtkwave-3.2.1.ebuild,v 1.1 2009/07/11 20:14:17 calchan Exp $

EAPI="2"

DESCRIPTION="A wave viewer for LXT, LXT2, VZT, GHW and standard Verilog VCD/EVCD files"
HOMEPAGE="http://gtkwave.sourceforge.net/"

SRC_URI="http://gtkwave.sourceforge.net/${P}.tar.gz"

IUSE="doc examples"
LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"

RDEPEND=">=dev-libs/glib-2
	>=x11-libs/gtk+-2
	x11-libs/pango"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/gperf"

src_prepare(){
	sed -i -e 's/doc examples//' Makefile.in || die "sed failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"
	dodoc ANALOG_README.TXT CHANGELOG.TXT
	if use doc ; then
		insinto /usr/share/doc/${PF}
		doins "doc/${PN}.odt" || die "Failed to install documentation."
	fi
	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples || die "Failed to install examples."
	fi
}
