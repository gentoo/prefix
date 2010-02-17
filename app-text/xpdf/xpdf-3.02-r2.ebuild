# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xpdf/xpdf-3.02-r2.ebuild,v 1.10 2010/02/10 19:59:09 ssuominen Exp $

EAPI=2

inherit eutils flag-o-matic

DESCRIPTION="An X Viewer for PDF Files"
HOMEPAGE="http://www.foolabs.com/xpdf/"
SRC_URI="http://gentooexperimental.org/~genstef/dist/${P}-poppler-20071121.tar.bz2
	linguas_ar? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-arabic-2003-feb-16.tar.gz )
	linguas_zh_CN? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-chinese-simplified-2004-jul-27.tar.gz )
	linguas_zh_TW? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-chinese-traditional-2004-jul-27.tar.gz )
	linguas_ru? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-cyrillic-2003-jun-28.tar.gz )
	linguas_el? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-greek-2003-jun-28.tar.gz )
	linguas_he? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-hebrew-2003-feb-16.tar.gz )
	linguas_ja? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-japanese-2004-jul-27.tar.gz )
	linguas_ko? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-korean-2005-jul-07.tar.gz )
	linguas_la? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-latin2-2002-oct-22.tar.gz )
	linguas_th? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-thai-2002-jan-16.tar.gz )
	linguas_tr? ( ftp://ftp.foolabs.com/pub/xpdf/xpdf-turkish-2002-apr-10.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="nodrm linguas_ar linguas_zh_CN linguas_zh_TW linguas_ru linguas_el linguas_he linguas_ja linguas_ko linguas_la linguas_th linguas_tr"

RDEPEND="app-text/poppler
	x11-libs/openmotif
	x11-libs/libX11
	x11-libs/libXpm"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${P}-poppler

pkg_setup() {
	append-flags '-DSYSTEM_XPDFRC="\"/etc/xpdfrc\""'
}

src_prepare() {
	use nodrm && epatch "${FILESDIR}/${P}-poppler-nodrm.patch"
	epatch "${FILESDIR}/${P}-poppler-0.10.0.patch"
	epatch "${FILESDIR}/${P}-poppler-0.11.0.patch"
	epatch "${FILESDIR}/${P}-as-needed.patch"
	epatch "${FILESDIR}"/${P}-darwin.patch
}

src_install() {
	dobin xpdf
	doman xpdf.1 "${FILESDIR}"/xpdfrc.5
	insinto /etc
	newins "${FILESDIR}"/sample-xpdfrc xpdfrc
	dodoc README ANNOUNCE CHANGES

	use linguas_ar && install_lang arabic
	use linguas_zh_CN && install_lang chinese-simplified
	use linguas_zh_TW && install_lang chinese-traditional
	use linguas_ru && install_lang cyrillic
	use linguas_el && install_lang greek
	use linguas_he && install_lang hebrew
	use linguas_ja && install_lang japanese
	use linguas_ko && install_lang korean
	use linguas_la && install_lang latin2
	use linguas_th && install_lang thai
	use linguas_tr && install_lang turkish
}

install_lang() {
	cd ../xpdf-$1
	sed 's,/usr/local/share/xpdf/,'"${EPREFIX}"'/usr/share/xpdf/,g' add-to-xpdfrc >> "${ED}"/etc/xpdfrc
	insinto /usr/share/xpdf/$1
	doins -r *.unicodeMap *ToUnicode
	[[ -d CMap ]] && doins -r CMap
}
