# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/bfm/bfm-0.6.4.ebuild,v 1.5 2007/01/26 14:43:53 s4t4n Exp $

EAPI="prefix"

inherit eutils

IUSE=""

DESCRIPTION="Dock application that combines timecop's bubblemon and wmfishtime together."
HOMEPAGE="http://www.jnrowe.ukfsn.org/projects/bfm.html"
SRC_URI="http://www.jnrowe.ukfsn.org/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=x11-libs/gtk+-2.4.9-r1"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack()
{
	unpack ${A}
	cd ${S}

	# Patch to honour Gentoo CFLAGS
	epatch ${FILESDIR}/${P}-Makefile.patch
}

src_compile()
{
	emake GENTOO_CFLAGS="${CFLAGS}" || die "Compilation failed"
}

src_install ()
{
	dodoc ChangeLog README doc/Xdefaults.sample README.bubblemon
	einstall PREFIX="${ED}/usr" || die "Installation failed"
}
