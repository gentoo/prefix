# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/sharutils/sharutils-4.6.3.ebuild,v 1.11 2009/03/18 14:40:46 ricmm Exp $

EAPI="prefix"

inherit eutils

MY_P="${P/_/-}"
DESCRIPTION="Tools to deal with shar archives"
HOMEPAGE="http://www.gnu.org/software/sharutils/"
SRC_URI="mirror://gnu/${PN}/REL-${PV}/${P}.tar.bz2
		doc? ( mirror://gnu/${PN}/REL-${PV}/${P}-doc.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="nls doc"

DEPEND="sys-apps/texinfo
	nls? ( >=sys-devel/gettext-0.10.35 )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	strip-linguas -u po
	econf $(use_enable nls) || die
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
	if use doc ; then
		mv html_chapter/ html_node sharutils.html html_mono/ \
			pdf/sharutils.pdf.gz "${ED}/usr/share/doc/${PF}" \
			|| die 'documentation installation failed'
		rm "${ED}"/usr/share/doc/${PF}/*/*.gz
	fi
}
