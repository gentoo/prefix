# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/slang/slang-2.0.6.ebuild,v 1.4 2006/09/19 22:48:21 liquidx Exp $

EAPI="prefix"

inherit eutils multilib

DESCRIPTION="Console display library used by most text viewer"
HOMEPAGE="http://www.s-lang.org/"
SRC_URI="ftp://space.mit.edu/pub/davis/slang/v${PV%.*}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
# USE=cjk is broken; see http://www.jedsoft.org/pipermail/slang-users_jedsoft.org/2006/000399.html
IUSE="pcre png"

DEPEND=">=sys-libs/ncurses-5.2-r2
	pcre? ( dev-libs/libpcre )
	png? ( media-libs/libpng )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e '/^SLANG_INST_INC/s/-I@includedir@/-I@SRCDIR@ -I@includedir@/' \
		-e '/^SLANG_INST_LIB/s/-L@libdir@/-L@OBJDIR@ -L@ELFDIR@ -L@libdir@/' \
		slsh/Makefile.in || die

	epatch "${FILESDIR}/${PN}-2.0.6-slsh-libs.patch"
	epatch "${FILESDIR}/${PN}-2.0.6-foreground.patch"

	grep -rlZ -- '-lslang\>' "${S}" | xargs -0 sed -i -e 's:-lslang:-lslang-2:g'
}

src_compile() {
	econf \
		$(use_with pcre) \
		$(use_with png) || die "econf failed"
	emake -j1 THIS_LIB="slang-2" all || die "make all failed"
	emake -j1 THIS_LIB="slang-2" elf || die "make elf failed"
	cd slsh
	emake -j1 THIS_LIB="slang-2" slsh || die "make slsh failed"
}

src_install() {
	emake -j1 THIS_LIB="slang-2" DESTDIR="${D}" install install-elf || die "make install failed"

	# Move headers around
	dodir /usr/include/slang-2
	mv "${ED}"/usr/include/*.h "${ED}/usr/include/slang-2"

	rm -rf "${ED}/usr/share/doc/slang"
	dodoc NEWS README *.txt
	dodoc doc/*.txt doc/internal/*.txt doc/text/*.txt
	dohtml doc/slangdoc.html
}

pkg_postinst() {
	elog "For compatibility reason slang 2.x is installed in Gentoo as libslang-2."
	elog "This has the unfortunate consequence that if you want to build something"
	elog "from sources that uses slang 2.x, you need to change the linking library"
	elog "to -lslang-2 instead of simply -lslang."
	elog "We're sorry for the inconvenience, but it's to overcome an otherwise"
	elog "problematic situation."
}
