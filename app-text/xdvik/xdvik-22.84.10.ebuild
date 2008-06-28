# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xdvik/xdvik-22.84.10.ebuild,v 1.22 2008/06/27 10:00:14 ulm Exp $

EAPI="prefix"

WANT_AUTOCONF=2.1

inherit eutils flag-o-matic elisp-common autotools

XDVIK_JP="${P}-j1.33.patch.gz"

DESCRIPTION="DVI previewer for X Window System"
HOMEPAGE="http://sourceforge.net/projects/xdvi/ http://xdvi.sourceforge.jp/"
SRC_URI="mirror://sourceforge/xdvi/${P}.tar.gz
	cjk? ( mirror://sourceforge.jp/xdvi/20703/${XDVIK_JP} )"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
SLOT="0"
LICENSE="GPL-2"
IUSE="cjk motif neXt Xaw3d emacs"

RDEPEND=">=media-libs/t1lib-5.0.2
	x11-libs/libXmu
	x11-libs/libXp
	x11-libs/libXpm
	motif? ( x11-libs/openmotif )
	!motif? ( neXt? ( x11-libs/neXtaw )
		!neXt? ( Xaw3d? ( x11-libs/Xaw3d ) ) )
	cjk? ( || ( app-text/texlive-core app-text/ptex )
		>=media-libs/freetype-2
		>=media-fonts/kochi-substitute-20030809-r3 )
	!cjk? ( virtual/latex-base )
	!<app-text/texlive-2007"
DEPEND="${RDEPEND}"

# pkg_setup() {
# 	if has_version virtual/tetex && built_with_use virtual/tetex X ; then
# 		eerror "tetex provides xdvik when built with the X flag."
# 		eerror "To install this version of xdvik re-install tetex"
# 		eerror "without the X flag."
# 		die "xdvik collides with tetex built with the X flag"
# 	fi
# }

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"
	if use cjk ; then
		epatch "${DISTDIR}/${XDVIK_JP}"
		cat >>"${S}/texk/xdvik/vfontmap.sample"<<-EOF

		# TrueType fonts
		min     /usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		nmin    /usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		goth    /usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		tmin    /usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		tgoth   /usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		ngoth   /usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		jis     /usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		jisg    /usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		dm      /usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		dg      /usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		mgoth   /usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		fmin    /usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		fgoth   /usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		EOF
	fi
	epatch "${FILESDIR}"/${PN}-asneeded.patch
	cd texk/xdvik
	eautoconf -m ../etc/autoconf
}

src_compile() {

	local TEXMF_PATH=$(kpsewhich --expand-var='$TEXMFMAIN')
	local myconf toolkit

	if use motif ; then
		toolkit="motif"
	elif use neXt ; then
		toolkit="neXtaw"
	elif use Xaw3d ; then
		toolkit="xaw3d"
	else
		toolkit="xaw"
	fi

	econf --disable-multiplatform \
		--enable-t1lib \
		--enable-gf \
		--with-system-t1lib \
		--with-xdvi-x-toolkit="${toolkit}" \
		${myconf} || die "econf failed"

	cd texk/xdvik
	emake texmf="${TEXMF_PATH}" || die
	use emacs && elisp-compile xdvi-search.el
}

src_install() {

	dodir /etc/texmf/xdvi /etc/X11/app-defaults

	local TEXMF_PATH=$(kpsewhich --expand-var='$TEXMFMAIN')

	cd "${S}/texk/xdvik"
	einstall texmf="${D}${TEXMF_PATH}" || die "install failed"

	mv "${D}${TEXMF_PATH}/xdvi/XDvi" "${ED}etc/X11/app-defaults"
	dosym {/etc/X11/app-defaults,"${TEXMF_PATH#${EPREFIX}}"}/XDvi
	for i in $(find "${D}${TEXMF_PATH}/xdvi" -type f -maxdepth 1) ; do
		mv ${i} "${ED}etc/texmf/xdvi"
		dosym {/etc/texmf,"${TEXMF_PATH#${EPREFIX}}"}/xdvi/$(basename ${i})
	done

	dodoc BUGS FAQ README.*
	if use cjk; then
		dodoc CHANGES.xdvik-jp
		docinto READMEs
		dodoc READMEs/*
	fi

	use emacs && elisp-install tex-utils *.el *.elc
}

pkg_postinst() {
	if use emacs; then
		elog "Add"
		elog "	(add-to-list 'load-path \"${SITELISP}/tex-utils\")"
		elog "	(require 'xdvi-search)"
		elog "to your ~/.emacs file"
	fi
}
