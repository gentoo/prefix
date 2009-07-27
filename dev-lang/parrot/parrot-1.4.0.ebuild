# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/parrot/parrot-1.4.0.ebuild,v 1.1 2009/07/25 09:48:29 patrick Exp $

EAPI=2

inherit eutils multilib

DESCRIPTION="Parrot is a virtual machine designed to efficiently compile and execute bytecode for dynamic languages"
HOMEPAGE="http://www.parrot.org/"
SRC_URI="ftp://ftp.parrot.org/pub/parrot/releases/stable/${PV}/${P}.tar.gz"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="opengl nls doc examples gdbm gmp ssl unicode pcre"

RDEPEND="opengl? ( virtual/glut )
		 nls? ( sys-devel/gettext )
		 unicode? ( >=dev-libs/icu-2.6 )
		 gdbm? ( >=sys-libs/gdbm-1.8.3-r1 )
		 gmp? ( >=dev-libs/gmp-4.1.4 )
		 ssl? ( dev-libs/openssl )
		 pcre? ( dev-libs/libpcre )"

DEPEND="dev-lang/perl[doc?]
		${RDEPEND}"

src_prepare() {
	sed -e "s:/lib/:/$(get_libdir)/:" -i "${S}/tools/dev/install_files.pl"
}

src_configure() {
	myconf=""
	use unicode || myconf="$myconf --without-icu"
	use ssl || myconf="$myconf --without-crypto"
	use gdbm || myconf="$myconf --without-gdbm"
	use nls || myconf="$myconf --without-gettext"
	use gmp || myconf="$myconf --without-gmp"
	use opengl || myconf="$myconf --without-opengl"
	use pcre || myconf="$myconf --without-pcre"

	perl Configure.pl --prefix="${EPREFIX}"/usr \
					  --libdir="${EPREFIX}"/usr/$(get_libdir) \
					  --sysconfdir="${EPREFIX}"/etc \
					  --sharedstatedir="${EPREFIX}"/var/lib/parrot \
					  $myconf
}

src_compile() {
	emake || die
	use doc && make html
}

src_install() {
	emake -j1 install-dev DESTDIR="${D}" DOC_DIR="${EPREFIX}/usr/share/doc/${P}" || die
}
