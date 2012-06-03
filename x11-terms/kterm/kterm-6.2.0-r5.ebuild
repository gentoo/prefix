# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/kterm/kterm-6.2.0-r5.ebuild,v 1.7 2012/05/31 08:27:25 ago Exp $

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Japanese Kanji X Terminal"
SRC_URI="ftp://ftp.x.org/contrib/applications/${P}.tar.gz
	http://www.asahi-net.or.jp/~hc3j-tkg/kterm/${P}-wpi.patch.gz
	http://www.st.rim.or.jp/~hanataka/${P}.ext02.patch.gz"
# until someone who reads japanese can find a better place
HOMEPAGE="http://www.asahi-net.or.jp/~hc3j-tkg/kterm/"

LICENSE="MIT as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="Xaw3d"

RDEPEND="app-text/rman
	sys-libs/ncurses
	x11-libs/libXmu
	x11-libs/libXpm
	x11-libs/libxkbfile
	x11-libs/libXaw
	x11-libs/libXp
	Xaw3d? ( x11-libs/libXaw3d )"
DEPEND="${RDEPEND}
	x11-misc/gccmakedep
	x11-misc/imake"

src_unpack(){
	unpack ${A}

	cd "${S}"
	epatch "${WORKDIR}"/${P}-wpi.patch		# wallpaper patch
	epatch "${WORKDIR}"/${P}.ext02.patch		# JIS 0213 support
	epatch "${FILESDIR}"/${P}-openpty.patch
	epatch "${FILESDIR}"/${P}-gentoo.patch
	epatch "${FILESDIR}"/${PN}-ad-gentoo.diff
	epatch "${FILESDIR}"/${PV}-underline.patch

	if use Xaw3d ; then
		epatch "${FILESDIR}"/kterm-6.2.0-Xaw3d.patch
	fi
}

src_compile(){
	xmkmf -a || die
	emake CC="$(tc-getCC)" CDEBUGFLAGS="${CFLAGS}" LOCAL_LDFLAGS="${LDFLAGS}" \
		XAPPLOADDIR="${EPREFIX}"/usr/share/X11/app-defaults || die "emake failed"
}

src_install(){
	emake DESTDIR="${D}" BINDIR="${EPREFIX}"/usr/bin XAPPLOADDIR="${EPREFIX}"/usr/share/X11/app-defaults install || die

	# install man pages
	newman kterm.man kterm.1
	insinto /usr/share/man/ja/man1
	iconv -f ISO-2022-JP -t EUC-JP kterm.jman > kterm.ja.1
	newins kterm.ja.1 kterm.1

	# Remove link to avoid collision
	rm -f "${ED}"/usr/lib/X11/app-defaults

	dodoc README.kt
}

pkg_postinst() {
	elog
	elog "KTerm wallpaper support is enabled."
	elog "In order to use this feature,"
	elog "you need specify favourite xpm file with -wp option"
	elog
	elog "\t% kterm -wp filename.xpm"
	elog
	elog "or set it with X resource"
	elog
	elog "\tKTerm*wallPaper: /path/to/filename.xpm"
	elog
}
