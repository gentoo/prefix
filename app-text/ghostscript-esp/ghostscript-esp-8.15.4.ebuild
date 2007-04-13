# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/ghostscript-esp/ghostscript-esp-8.15.4.ebuild,v 1.1 2007/03/20 13:39:28 genstef Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit autotools elisp-common eutils versionator

DESCRIPTION="ESP Ghostscript -- an enhanced version of GPL Ghostscript with better printer support"
HOMEPAGE="http://www.cups.org/espgs"

GSDJVU_PV=1.1
MY_P=espgs-${PV}
PVM=$(get_version_component_range 1-2)
SRC_URI="cjk? ( ftp://ftp.gyve.org/pub/gs-cjk/adobe-cmaps-200406.tar.gz
		ftp://ftp.gyve.org/pub/gs-cjk/acro5-cmaps-2001.tar.gz )
		djvu? ( mirror://sourceforge/djvu/gsdjvu-${GSDJVU_PV}.tar.gz )
		http://ftp.rz.tu-bs.de/pub/mirror/ftp.easysw.com/ftp/pub/ghostscript/${PV}/espgs-${PV}-source.tar.bz2
		ftp://ftp3.easysw.com/pub/ghostscript/${PV}/espgs-${PV}-source.tar.bz2"
ESVN_REPO_URI="http://svn.easysw.com/public/espgs/trunk"

LICENSE="GPL-2 LGPL-2 CPL-1.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="X cups cjk emacs gtk threads xml djvu"

DEP="virtual/libc
	virtual/libiconv
	>=media-libs/jpeg-6b
	>=media-libs/libpng-1.2.5
	>=sys-libs/zlib-1.1.4
	>=media-libs/tiff-3.7
	X? ( || ( x11-libs/libXt virtual/x11 ) )
	djvu? ( app-text/djvu )
	gtk? ( >=x11-libs/gtk+-2.0 )
	cups? ( >=net-print/cups-1.1.20 )
	xml? ( >=dev-libs/libxml2-2.6.8 )
	media-libs/fontconfig
	!app-text/ghostscript-gnu
	!app-text/ghostscript-gpl"

RDEPEND="${DEP}
	cjk? ( media-fonts/arphicfonts
		media-fonts/kochi-substitute
		media-fonts/baekmuk-fonts )
	media-fonts/gnu-gs-fonts-std"

DEPEND="${DEP}
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A/adobe-cmaps-200406.tar.gz acro5-cmaps-2001.tar.gz}
	if use cjk; then
		cat ${FILESDIR}/ghostscript-esp-8.15.2-cidfmap.cjk >> ${S}/lib/cidfmap
		cat ${FILESDIR}/ghostscript-esp-8.15.2-FAPIcidfmap.cjk >> ${S}/lib/FAPIcidfmap
		cd ${S}/Resource
		unpack adobe-cmaps-200406.tar.gz
		unpack acro5-cmaps-2001.tar.gz
	fi
	cd ${S}

	# http://cups.org/espgs/str.php?L2000
	epatch ${FILESDIR}/ghostscript-esp-8.15.1-fPIC.patch

	if use djvu; then
		unpack gsdjvu-${GSDJVU_PV}.tar.gz
		cp gsdjvu-${GSDJVU_PV}/gsdjvu ${S}
		cp gsdjvu-${GSDJVU_PV}/gdevdjvu.c ${S}/src
		cp gsdjvu-${GSDJVU_PV}/ps2utf8.ps ${S}/lib
		cp ${S}/src/contrib.mak ${S}/src/contrib.mak.gsdjvu
		grep -q djvusep ${S}/src/contrib.mak || \
			cat gsdjvu-${GSDJVU_PV}/gsdjvu.mak >> ${S}/src/contrib.mak
	fi

	# search path fix
	sed -i -e "s:\$\(gsdatadir\)/lib:${EPREFIX}/usr/share/ghostscript/${PVM}/$(get_libdir):" \
		-e 's:$(gsdir)/fonts:'"${EPREFIX}"'/usr/share/fonts/default/ghostscript/:' \
		-e "s:exdir=.*:exdir=${EPREFIX}/usr/share/doc/${PF}/examples:" \
		src/Makefile.in || die "sed failed"
	sed -i -e "s:docdir=.*:docdir=${EPREFIX}/usr/share/doc/${PF}/html:" \
		-e "s:GS_DOCDIR=.*:GS_DOCDIR=${EPREFIX}/usr/share/doc/${PF}/html:" \
		src/Makefile.in src/*.mak || die "sed failed"

	epatch "${FILESDIR}"/ghostscript-esp-8.15.3-darwin.patch
	cp "${EPREFIX}"/usr/share/automake-1.9/install-sh "${S}"
	AT_NOELIBTOOLIZE="yes" eautoreconf
	cd ijs
	# remove stupid absolute symlinks
	rm install-sh ltmain.sh missing config.guess config.sub
	ln -s ../install-sh
	ln -s ../ltmain.sh
	ln -s ../missing
	AT_NOELIBTOOLIZE="yes" eautoreconf
	elibtoolize
}

src_compile() {
	local myconf=""
	use elibc_glibc || myconf="--with-libiconv=gnu"
	econf $(use_with X x) \
		$(use_enable gtk) \
		$(use_enable cups) \
		$(use_enable threads) \
		$(use_with xml omni) \
		${myconf} \
		--with-fontconfig \
		--with-ijs \
		--with-jbig2dec || die "econf failed"

	if use djvu; then
		sed -i -e 's!$(DD)bbox.dev!& $(DD)djvumask.dev $(DD)djvusep.dev!g'		Makefile
		sed -i -e 's:(/\(Resource/[a-zA-Z/]*\)):(\1) findlibfile {pop} {pop &}
		ifelse:' lib/gs_res.ps
	fi

	emake -j1 so all || die "emake failed"

	cd ijs
	econf || die "ijs econf failed"
	emake || die "ijs emake failed"
}

src_install() {
	emake install_prefix="${D}" install soinstall || die "emake install failed"

	use djvu && dobin gsdjvu

	rm -fr ${ED}/usr/share/doc/${PF}/html/{README,PUBLIC}
	dodoc doc/README
	use emacs && elisp-site-file-install doc/gsdoc.el

	cd ${S}/ijs
	emake DESTDIR="${D}" install || die "emake ijs install failed"
}

pkg_postinst() {
	ewarn "If you are upgrading from ghostscript-7 you need to rebuild"
	ewarn "gimp-print. Please run 'revdep-rebuild' to do this."
}
