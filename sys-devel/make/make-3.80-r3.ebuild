# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/make/make-3.80-r3.ebuild,v 1.1 2005/09/29 22:31:41 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DESCRIPTION="Standard tool to compile source trees"
HOMEPAGE="http://www.gnu.org/software/make/make.html"
SRC_URI="ftp://ftp.gnu.org/gnu/make/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="nls static build"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PV}-memory.patch
	epatch "${FILESDIR}"/${P}-parallel-build-failure.patch
}

src_compile() {
	use static && append-ldflags -static
	econf \
		$(use_enable nls) \
		--program-prefix=g \
		|| die
	emake || die
}

src_install() {
	if use build ; then
		if [[ ${USERLAND} == "GNU" ]] ; then
			dobin make || die "dobin"
		else
			newbin make gmake || die "newbin failed"
		fi
	else
		make DESTDIR="${DEST}" install || die "make install failed"
		dodoc AUTHORS ChangeLog NEWS README*
		if [[ ${USERLAND} == "GNU" ]] ; then
			dosym gmake /usr/bin/make
			dosym gmake.1 /usr/share/man/man1/make.1
		fi
	fi
}
