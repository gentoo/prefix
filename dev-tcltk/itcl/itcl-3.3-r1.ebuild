# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tcltk/itcl/itcl-3.3-r1.ebuild,v 1.6 2006/05/24 20:15:44 hansmi Exp $

inherit eutils

MY_P="${PN}${PV}"
DESCRIPTION="Object Oriented Enhancements for Tcl/Tk"
HOMEPAGE="http://incrtcl.sourceforge.net/"
SRC_URI="mirror://sourceforge/incrtcl/${MY_P}.tar.gz"

IUSE=""
SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DEPEND="dev-lang/tcl"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e "s/relid'/relid/" configure tclconfig/tcl.m4 || die
}

src_compile() {
	econf || die "econf failed"

	# adjust install_name on darwin
	if [[ ${CHOST} == *-darwin* ]]; then
		sed -i \
			-e 's:^\(SHLIB_LD\W.*\)$:\1 -install_name ${pkglibdir}/$@:' \
			"${S}"/Makefile || die 'sed failed'
	fi

	emake CFLAGS_DEFAULT="${CFLAGS}" || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc CHANGES ChangeLog INCOMPATIBLE README TODO
}
