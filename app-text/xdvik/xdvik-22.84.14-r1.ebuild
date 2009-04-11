# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xdvik/xdvik-22.84.14-r1.ebuild,v 1.1 2009/02/08 11:07:00 aballier Exp $

inherit eutils flag-o-matic elisp-common toolchain-funcs

XDVIK_JP="${P}-j1.40.patch.gz"

DESCRIPTION="DVI previewer for X Window System"
HOMEPAGE="http://xdvi.sourceforge.net/ http://xdvi.sourceforge.jp/"
SRC_URI="mirror://sourceforge/xdvi/${P}.tar.gz
	cjk? ( mirror://sourceforge.jp/xdvi/31972/${XDVIK_JP} )"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
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

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"
	if use cjk ; then
		epatch "${DISTDIR}/${XDVIK_JP}"
		cat >>"${S}/texk/xdvik/vfontmap.sample"<<-EOF

		# TrueType fonts
		min     ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		nmin    ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		goth    ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		tmin    ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		tgoth   ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		ngoth   ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		jis     ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		jisg    ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		dm      ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		dg      ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		mgoth   ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		fmin    ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf
		fgoth   ${EPREFIX}/usr/share/fonts/kochi-substitute/kochi-gothic-subst.ttf
		EOF
	fi
}

src_compile() {
	tc-export CC AR RANLIB

	local TEXMF_PATH=$(${EPREFIX}/usr/bin/kpsewhich --expand-var='$TEXMFMAIN')
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
		--with-system-kpathsea \
		--with-kpathsea-include="${EPREFIX}"/usr/include/kpathsea \
		--with-xdvi-x-toolkit="${toolkit}" \
		${myconf} || die "econf failed"

	cd texk/xdvik
	emake kpathsea_dir="${EPREFIX}/usr/include/kpathsea" texmf="${TEXMF_PATH}" || die
	use emacs && elisp-compile xdvi-search.el
}

src_install() {

	dodir /etc/texmf/xdvi /etc/X11/app-defaults

	local TEXMF_PATH=$(kpsewhich --expand-var='$TEXMFMAIN')

	cd "${S}/texk/xdvik"
	einstall kpathsea_dir="${EPREFIX}/usr/include/kpathsea" texmf="${D}${TEXMF_PATH}" || die "install failed"

	mv "${D}${TEXMF_PATH}/xdvi/XDvi" "${ED}etc/X11/app-defaults" || die "failed to move config file"
	dosym {/etc/X11/app-defaults,"${TEXMF_PATH#${EPREFIX}}/xdvi"}/XDvi || die "failed to symlink config file"
	for i in $(find "${D}${TEXMF_PATH}/xdvi" -type f -maxdepth 1) ; do
		mv ${i} "${ED}etc/texmf/xdvi" || die "failed to move $i"
		dosym {/etc/texmf,"${TEXMF_PATH#${EPREFIX}}"}/xdvi/$(basename ${i}) || die "failed	to symlink $i"
	done

	dodoc BUGS FAQ README.* || die "dodoc failed"
	if use cjk; then
		dodoc CHANGES.xdvik-jp || die "dodoc failed"
		docinto READMEs
		dodoc READMEs/* || die "dodoc failed"
	fi

	use emacs && elisp-install tex-utils *.el *.elc
	doicon "${FILESDIR}/${PN}.png"
	make_desktop_entry xdvi "XDVI" xdvik "Graphics;Viewer"
	echo "MimeType=application/x-dvi;" >> "${ED}"usr/share/applications/xdvi-"${PN}".desktop
}

pkg_postinst() {
	if use emacs; then
		elog "Add"
		elog "	(add-to-list 'load-path \"${SITELISP}/tex-utils\")"
		elog "	(require 'xdvi-search)"
		elog "to your ~/.emacs file"
	fi
}
