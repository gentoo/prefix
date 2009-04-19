# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tcltk/itcl/itcl-3.3.1_pre20090417.ebuild,v 1.1 2009/04/18 08:59:59 mescalinum Exp $

inherit eutils

MY_PN="incrTcl"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Object Oriented Enhancements for Tcl/Tk"
HOMEPAGE="http://incrtcl.sourceforge.net/"
SRC_URI="mirror://gentoo/${MY_P}.tar.gz"

IUSE=""
SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DEPEND="dev-lang/tcl"

S="${WORKDIR}/${MY_PN}/${PN}"

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
	dodoc ../{CHANGES,ChangeLog,INCOMPATIBLE,README,TODO}
}
