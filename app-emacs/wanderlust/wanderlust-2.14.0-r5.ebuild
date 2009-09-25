# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/wanderlust/wanderlust-2.14.0-r5.ebuild,v 1.3 2009/09/22 14:03:28 armin76 Exp $

inherit elisp eutils

MY_P="wl-${PV/_/}"

DESCRIPTION="Yet Another Message Interface on Emacsen"
HOMEPAGE="http://www.gohome.org/wl/"
SRC_URI="ftp://ftp.gohome.org/wl/stable/${MY_P}.tar.gz
	ftp://ftp.gohome.org/wl/beta/${MY_P}.tar.gz
	http://dev.gentoo.org/~usata/distfiles/${MY_P}-20050405.diff"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="bbdb ssl linguas_ja"

DEPEND=">=app-emacs/apel-10.6
	virtual/flim
	app-emacs/semi
	bbdb? ( app-emacs/bbdb )"
RDEPEND="!app-emacs/wanderlust-cvs
	${DEPEND}"

S="${WORKDIR}/${MY_P}"
SITEFILE="50${PN}-gentoo.el"

src_unpack() {
	unpack ${MY_P}.tar.gz

	cd "${S}"
	epatch "${DISTDIR}/${MY_P}-20050405.diff"
	epatch "${FILESDIR}/${P}-smtp-end-of-line.patch"
	epatch "${FILESDIR}/${P}-texinfo-garbage.patch"
}

src_compile() {
	local lang="\"en\""
	use linguas_ja && lang="${lang} \"ja\""
	echo "(setq wl-info-lang '(${lang}) wl-news-lang '(${lang}))" >>WL-CFG
	use ssl && echo "(setq wl-install-utils t)" >>WL-CFG

	emake || die "emake failed"
	emake info || die "emake info failed"
}

src_install() {
	emake \
		LISPDIR="${ED}${SITELISP}" \
		PIXMAPDIR="${ED}${SITEETC}/wl/icons" \
		install || die "emake install failed"

	elisp-site-file-install "${FILESDIR}/${SITEFILE}" wl || die

	insinto "${SITEETC}/wl/samples/en"
	doins samples/en/*
	doinfo doc/wl*.info
	dodoc BUGS ChangeLog INSTALL NEWS README

	if use linguas_ja; then
		insinto "${SITEETC}/wl/samples/ja"
		doins samples/ja/*
		dodoc BUGS.ja INSTALL.ja NEWS.ja README.ja
	fi
}
