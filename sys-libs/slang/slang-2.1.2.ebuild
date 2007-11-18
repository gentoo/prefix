# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/slang/slang-2.1.2.ebuild,v 1.2 2007/11/16 16:51:49 fmccor Exp $

EAPI="prefix"

inherit eutils multilib

DESCRIPTION="Console display library used by most text viewer"
HOMEPAGE="http://www.s-lang.org/"
SRC_URI="ftp://space.mit.edu/pub/davis/slang/v${PV%.*}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
# USE=cjk is broken; see http://www.jedsoft.org/pipermail/slang-users_jedsoft.org/2006/000399.html
IUSE="pcre png"

DEPEND=">=sys-libs/ncurses-5.2-r2
	pcre? ( dev-libs/libpcre )
	png? ( media-libs/libpng )"

MAKEOPTS="${MAKEOPTS} -j1"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-slsh-libs.patch"

	sed -i -e '/^THIS_LIB/s/slang/slang-2/' src/Makefile.in || die

	grep -rlZ -- '-lslang\>' "${S}" | xargs -0 sed -i -e 's:-lslang:-lslang-2:g'
}

src_compile() {
	econf \
		$(use_with pcre) \
		$(use_with png) || die "econf failed"
	emake all || die "make all failed"
	cd slsh
	emake slsh || die "make slsh failed"
}

src_install() {
	emake DESTDIR="${D}" install install-static || die "make install failed"

	# Move headers around
	dodir /usr/include/slang-2
	mv "${ED}"/usr/include/*.h "${ED}/usr/include/slang-2"

	rm -rf "${ED}/usr/share/doc/{slang,slsh}"

	dodoc NEWS README *.txt
	dodoc doc/*.txt doc/internal/*.txt doc/text/*.txt
	dohtml doc/slangdoc.html
	dohtml slsh/doc/html/*.html
}

pkg_postinst() {
	elog "For compatibility reason slang 2.x is installed in Gentoo as libslang-2."
	elog "This has the unfortunate consequence that if you want to build something"
	elog "from sources that uses slang 2.x, you need to change the linking library"
	elog "to -lslang-2 instead of simply -lslang."
	elog "We're sorry for the inconvenience, but it's to overcome an otherwise"
	elog "problematic situation."
}
