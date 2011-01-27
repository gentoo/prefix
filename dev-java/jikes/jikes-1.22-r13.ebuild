# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jikes/jikes-1.22-r13.ebuild,v 1.12 2011/01/23 14:33:14 armin76 Exp $

inherit flag-o-matic eutils prefix

DESCRIPTION="IBM's open source, high performance Java compiler"
HOMEPAGE="http://jikes.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
LICENSE="IBM"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
DEPEND=""
RDEPEND=">=dev-java/java-config-2.0.0"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/deprecated.patch
}

src_compile() {
	filter-flags "-fno-rtti"
	econf || die "configure problem"
	emake || die "compile problem"
}

src_install () {
	make DESTDIR=${D} install || die "install problem"
	dodoc ChangeLog AUTHORS README TODO NEWS

	mv ${ED}/usr/bin/jikes{,-bin}
	sed \
		-e 's:\(#!\):\1@GENTOO_PORTAGE_EPREFIX@:' \
		-e 's:\(exec \):\1@GENTOO_PORTAGE_EPREFIX@:' \
			"${FILESDIR}"/jikes > jikes
	eprefixify jikes
	dobin jikes

	sed \
		-e 's:\(JAVAC=\):\1@GENTOO_PORTAGE_EPREFIX@:' \
			"${FILESDIR}"/compiler-settings > compiler-settings
	eprefixify compiler-settings
	insinto /usr/share/java-config-2/compiler
	newins compiler-settings
}
