# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/unison/unison-2.27.57.ebuild,v 1.1 2008/01/27 15:06:14 aballier Exp $

EAPI="prefix"

inherit eutils

IUSE="gtk doc static debug threads"

DESCRIPTION="Two-way cross-platform file synchronizer"
HOMEPAGE="http://www.cis.upenn.edu/~bcpierce/unison/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"

DEPEND=">=dev-lang/ocaml-3.04
	gtk? ( >=dev-ml/lablgtk-2.2 )"

RDEPEND="gtk? ( >=dev-ml/lablgtk-2.2
|| ( net-misc/x11-ssh-askpass net-misc/gtk2-ssh-askpass ) )"

PDEPEND="gtk? ( media-fonts/font-schumacher-misc )"

SRC_URI="http://www.cis.upenn.edu/~bcpierce/unison/download/releases/${P}/${P}.tar.gz
doc? ( http://www.cis.upenn.edu/~bcpierce/unison/download/releases/${P}/${P}-manual.pdf
	http://www.cis.upenn.edu/~bcpierce/unison/download/releases/${P}/${P}-manual.html )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-as-needed.patch"
}

src_compile() {
	local myconf

	if use threads; then
		myconf="$myconf THREADS=true"
	fi

	if use static; then
		myconf="$myconf STATIC=true"
	fi

	if use debug; then
		myconf="$myconf DEBUGGING=true"
	fi

	if use gtk; then
		myconf="$myconf UISTYLE=gtk2"
	else
		myconf="$myconf UISTYLE=text"
	fi

	# Discard cflags as it will try to pass them to ocamlc...
	emake -j1 $myconf CFLAGS="" || die "error making unsion"
}

src_test() {
	emake selftest ||  die "selftest failed"
}

src_install () {
	# install manually, since it's just too much
	# work to force the Makefile to do the right thing.
	dobin unison || die
	dodoc BUGS.txt CONTRIB INSTALL NEWS \
	      README ROADMAP.txt TODO.txt || die

	if use doc; then
		dohtml "${DISTDIR}/${P}-manual.html" || die
		dodoc "${DISTDIR}/${P}-manual.pdf" || die
	fi
}
