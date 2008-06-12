# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/sablotron/sablotron-1.0.3.ebuild,v 1.3 2008/01/25 19:17:14 grobian Exp $

EAPI="prefix"

inherit base autotools flag-o-matic

MY_PN="Sablot"
MY_P="${MY_PN}-${PV}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="An XSLT Parser in C++"
HOMEPAGE="http://www.gingerall.org/sablotron.html"
SRC_URI="http://download-1.gingerall.cz/download/sablot/${MY_P}.tar.gz"

# Sablotron can optionally be built under GPL, using MPL for now
LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc perl"

RDEPEND=">=dev-libs/expat-1.95.6-r1"
DEPEND="${RDEPEND}
	doc? ( >=dev-perl/XML-Parser-2.3 )"

PATCHES="${FILESDIR}/1.0.3-libsablot-expat.patch"

src_compile() {
	# Don't use --without-html-dir, since that ends up installing files under
	# the /no directory
	local myconf="--with-html-dir=${EPREFIX}/usr/share/doc/${PF}/html"

	# Please make sure at least elibtoolize is run, else we get references
	# to PORTAGE_TMPDIR in /usr/lib/libsablot.la ...
	eautoreconf

	use perl && myconf="${myconf} --enable-perlconnect"

	# rphillips, fixes bug #3876
	# this is fixed for me with apache2, but keeping it in here
	# for apache1 users and/or until some clever detection
	# is added <obz@gentoo.org>
	append-ldflags -lstdc++ -shared-libgcc

	econf ${myconf} || die "Configure failed"
	emake || die "Make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "Install failed"

	use doc || rm -rf "${ED}/usr/share/doc/${PF}/html"

	dodoc README README_JS RELEASE src/TODO
}
