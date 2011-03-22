# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/ghostscript-gpl/ghostscript-gpl-9.01.ebuild,v 1.1 2011/02/23 22:12:07 tgurr Exp $

EAPI=3
inherit autotools eutils versionator flag-o-matic

DESCRIPTION="Ghostscript is an interpreter for the PostScript language and for PDF"
HOMEPAGE="http://ghostscript.com/"

MY_P=${P/-gpl}
GSDJVU_PV=1.4
PVM=$(get_version_component_range 1-2)
SRC_URI="!bindist? ( djvu? ( mirror://sourceforge/djvu/gsdjvu-${GSDJVU_PV}.tar.gz ) )
	mirror://sourceforge/ghostscript/${MY_P}.tar.bz2
	mirror://gentoo/${P}-patchset-1.tar.bz2"

LICENSE="GPL-3 CPL-1.0"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="bindist cups djvu gtk idn jpeg2k X"

COMMON_DEPEND="app-text/libpaper
	media-libs/freetype:2
	media-libs/fontconfig
	virtual/jpeg
	>=media-libs/libpng-1.2.42
	>=media-libs/tiff-3.9.2
	>=sys-libs/zlib-1.2.3
	!bindist? ( djvu? ( app-text/djvu ) )
	cups? ( >=net-print/cups-1.3.8 )
	gtk? ( >=x11-libs/gtk+-2.0 )
	idn? ( net-dns/libidn )
	jpeg2k? ( media-libs/jasper )
	X? ( x11-libs/libXt x11-libs/libXext )"

DEPEND="${COMMON_DEPEND}
	app-arch/xz-utils
	dev-util/pkgconfig"

RDEPEND="${COMMON_DEPEND}
	>=app-text/poppler-data-0.4.4
	>=media-fonts/urw-fonts-2.4.9
	linguas_ja? ( media-fonts/kochi-substitute )
	linguas_ko? ( media-fonts/baekmuk-fonts )
	linguas_zh_CN? ( media-fonts/arphicfonts )
	linguas_zh_TW? ( media-fonts/arphicfonts )"

S="${WORKDIR}/${MY_P}"

LANGS="ja ko zh_CN zh_TW"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

pkg_setup() {
	if use bindist && use djvu; then
		ewarn "You have bindist in your USE, djvu support will NOT be compiled!"
		ewarn "See http://djvu.sourceforge.net/gsdjvu/COPYING for details on licensing issues."
	fi
}

src_prepare() {
	# remove internal copies of various libraries
	rm -rf "${S}/expat"
	rm -rf "${S}/jasper"
	rm -rf "${S}/jpeg"
	rm -rf "${S}/libpng"
	rm -rf "${S}/tiff"
	rm -rf "${S}/zlib"
	# remove internal urw-fonts
	rm -rf "${S}/Resource/Font"
	# remove internal CMaps (CMaps from poppler-data are used instead)
	rm -rf "${S}/Resource/CMap"

	# apply various patches, many borrowed from Fedora
	# http://pkgs.fedoraproject.org/gitweb/?p=ghostscript.git
	EPATCH_SUFFIX="patch" EPATCH_FORCE="yes"
	EPATCH_SOURCE="${WORKDIR}/patches/"
	epatch

	if ! use bindist && use djvu ; then
		unpack gsdjvu-${GSDJVU_PV}.tar.gz
		cp gsdjvu-${GSDJVU_PV}/gsdjvu "${S}"
		cp gsdjvu-${GSDJVU_PV}/gdevdjvu.c "${S}/base"
		epatch "${WORKDIR}/patches-gsdjvu/gsdjvu-1.3-${PN}-8.64.patch"
		epatch "${WORKDIR}/patches-gsdjvu/gsdjvu-1.4-${PN}-9.00-upstream-buildfixes.patch"
		# hard-coding paths sucks for Prefix
		epatch "${FILESDIR}"/${PN}-8.71-gsdjvu-1.3-partial-revert.patch
		cp gsdjvu-${GSDJVU_PV}/ps2utf8.ps "${S}/lib"
		cp "${S}/base/contrib.mak" "${S}/base/contrib.mak.gsdjvu"
		grep -q djvusep "${S}/base/contrib.mak" || \
			cat gsdjvu-${GSDJVU_PV}/gsdjvu.mak >> "${S}/base/contrib.mak"

		# install ps2utf8.ps, bug #197818
		sed -i -e '/$(EXTRA_INIT_FILES)/ a\ps2utf8.ps \\' "${S}/base/unixinst.mak" \
			|| die "sed failed"
	fi

	if ! use gtk ; then
		sed -i "s:\$(GSSOX)::" base/*.mak || die "gsx sed failed"
		sed -i "s:.*\$(GSSOX_XENAME)$::" base/*.mak || die "gsxso sed failed"
	fi

	# search path + compiler flags fix
	sed -i -e "s:\$(gsdatadir)/lib:${EPREFIX}/usr/share/ghostscript/${PVM}/$(get_libdir):" \
		-e "s:exdir=.*:exdir=${EPREFIX}/usr/share/doc/${PF}/examples:" \
		-e "s:docdir=.*:docdir=${EPREFIX}/usr/share/doc/${PF}/html:" \
		-e "s:GS_DOCDIR=.*:GS_DOCDIR=${EPREFIX}/usr/share/doc/${PF}/html:" \
		-e 's: -g : :g' \
		base/Makefile.in base/*.mak || die "sed failed"

	epatch "${FILESDIR}"/${P}-darwin.patch

	cd "${S}"
	eautoreconf
	# fails with non-bash on at least Solaris
	sed -i -e '1c\#!'"${EPREFIX}"'/bin/bash' configure || die

	cd "${S}/jbig2dec"
	eautoreconf

	cd "${S}/ijs"
	eautoreconf
}

src_configure() {
	local FONTPATH
	for path in \
		/usr/share/fonts/urw-fonts \
		/usr/share/fonts/Type1 \
		/usr/share/fonts \
		/usr/share/poppler/cMap/Adobe-CNS1 \
		/usr/share/poppler/cMap/Adobe-GB1 \
		/usr/share/poppler/cMap/Adobe-Japan1 \
		/usr/share/poppler/cMap/Adobe-Japan2 \
		/usr/share/poppler/cMap/Adobe-Korea1
	do
		FONTPATH="$FONTPATH${FONTPATH:+:}$path"
	done

	econf \
		$(use_enable cups) \
		$(use_enable gtk) \
		$(use_with cups pdftoraster) \
		$(use_with idn libidn) \
		$(use_with jpeg2k jasper) \
		$(use_with X x) \
		--disable-compile-inits \
		--enable-dynamic \
		--enable-freetype \
		--enable-fontconfig \
		--with-drivers=ALL \
		--with-fontpath="$FONTPATH" \
		--with-ijs \
		--with-jbig2dec \
		--with-libpaper \
		--with-system-libtiff

	if ! use bindist && use djvu ; then
		sed -i -e 's!$(DD)bbox.dev!& $(DD)djvumask.dev $(DD)djvusep.dev!g' Makefile
	fi

	cd "${S}/ijs"
	econf
}

src_compile() {
	emake -j1 so all || die "emake failed"

	cd "${S}/ijs"
	emake || die "ijs emake failed"
}

src_install() {
	emake DESTDIR="${D}" install-so install || die "emake install failed"

	if ! use bindist && use djvu ; then
		dobin gsdjvu || die "dobin gsdjvu install failed"
	fi

	# remove gsc in favor of gambit, bug #253064
	rm -rf "${ED}/usr/bin/gsc"

	rm -rf "${ED}/usr/share/doc/${PF}/html/"{README,PUBLIC}
	dodoc doc/GS9_Color_Management.pdf || die "dodoc install failed"

	cd "${S}/ijs"
	emake DESTDIR="${D}" install || die "emake ijs install failed"

	# rename the original cidfmap to cidfmap.GS
	mv "${ED}/usr/share/ghostscript/${PVM}/Resource/Init/cidfmap"{,.GS} || die

	# install our own cidfmap to handle CJK fonts
	insinto "/usr/share/ghostscript/${PVM}/Resource/Init"
	doins "${WORKDIR}/fontmaps/CIDFnmap" || die "doins CIDFnmap failed"
	doins "${WORKDIR}/fontmaps/cidfmap" || die "doins cidfmap failed"
	for X in ${LANGS} ; do
		if use linguas_${X} ; then
			doins "${WORKDIR}/fontmaps/cidfmap.${X}" || die "doins cidfmap.${X} failed"
		fi
	done
}
