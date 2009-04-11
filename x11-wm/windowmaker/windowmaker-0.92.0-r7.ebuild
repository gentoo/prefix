# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/windowmaker/windowmaker-0.92.0-r7.ebuild,v 1.8 2008/08/26 06:56:22 grobian Exp $

EAPI=1

inherit autotools eutils gnustep-base flag-o-matic

PATCHVER=1
S=${WORKDIR}/${P/windowm/WindowM}

DESCRIPTION="The fast and light GNUstep window manager"
SRC_URI="ftp://ftp.windowmaker.info/pub/source/release/${P/windowm/WindowM}.tar.gz
	http://www.windowmaker.info/pub/source/release/WindowMaker-extra-0.1.tar.gz
	http://www.gentoo.org/~grobian/distfiles/${P}-patchset-${PATCHVER}.tar.bz2"
HOMEPAGE="http://www.windowmaker.info/"

IUSE="gif gnustep jpeg nls png tiff modelock +vdesktop xinerama"
DEPEND="x11-libs/libXv
	>=x11-libs/libXft-2.1.0
	x11-libs/libXt
	media-libs/fontconfig
	gif? ( >=media-libs/giflib-4.1.0-r3 )
	png? ( >=media-libs/libpng-1.2.1 )
	jpeg? ( >=media-libs/jpeg-6b-r2 )
	tiff? ( >=media-libs/tiff-3.6.1-r2 )
	gnustep? ( >=gnustep-base/gnustep-make-2.0 )"
RDEPEND="${DEPEND}
	nls? ( >=sys-devel/gettext-0.10.39 )"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"

src_unpack() {
	is-flag -fstack-protector && filter-flags -fstack-protector \
		&& ewarn "CFLAG -fstack-protector has been disabled, as it is known to cause bugs with WindowMaker (bug #78051)" && ebeep 2
	replace-flags "-Os" "-O2"
	replace-flags "-O3" "-O2"

	unpack ${A}
	cd "${S}"
	local psd="${WORKDIR}"/${P}-patchset-${PATCHVER}

	epatch "${psd}"/WindowMaker-0.92.0-cvs20060123.patch
	epatch "${psd}"/WindowMaker-0.92.0-cvs-gcc41.patch
	epatch "${FILESDIR}"/${PV/0.92/0.91}/wlist-0.9x.patch
	epatch "${FILESDIR}"/${PV}/${P}-gif-before-ungif.patch
	epatch "${FILESDIR}"/${PV}/${P}-math_h.patch
	epatch "${FILESDIR}"/${PV}/${P}-gettext.patch

	# Patches from altlinux
	epatch "${psd}"/WindowMaker-0.91.0-alt-session.patch
	epatch "${psd}"/WindowMaker-0.91.0-alt-restartscrpt.patch
	epatch "${psd}"/WindowMaker-0.91.0-alt-menutrans.patch
	epatch "${psd}"/WindowMaker-0.91.0-alt-titlebar.patch
	epatch "${psd}"/WindowMaker-0.91.0-alt-clipnotext.patch
	epatch "${psd}"/WindowMaker-0.91.0-alt-mmx.patch
	epatch "${psd}"/WindowMaker-0.80.2-cvs-alt-textfield.patch
	epatch "${psd}"/WindowMaker-0.91.0-alt-focus.patch

	# New features (cool!)
	epatch "${FILESDIR}"/${PV/0.92/0.91}/singleclick-shadeormaxopts-0.9x.patch2
	epatch "${psd}"/WindowMaker-0.91.0-alt-dockhotkeys.patch
	epatch "${psd}"/WindowMaker-0.91.0-alt-vlaad-trance.patch
	epatch "${psd}"/WindowMaker-0.91.0-alt-vlaad-newbuttons.patch
	epatch "${psd}"/WindowMaker-0.91.0-alt-adialog.patch
	epatch "${psd}"/WindowMaker-0.91.0-hmepas-minimizeall.patch
	epatch "${psd}"/WindowMaker-0.91.0-hmepas-swmenu_rclick.patch
	epatch "${psd}"/WindowMaker-0.91.0-sga-moving-add.patch
	epatch "${psd}"/WindowMaker-0.91.0-peter-newappicon.patch
	epatch "${psd}"/WindowMaker-0.91.0-peter-mouse-placement.patch
	epatch "${psd}"/WindowMaker-0.91.0-peter-appicon-bouncer2.patch
	epatch "${psd}"/WindowMaker-0.91.0-sga-swpanel-customization.patch
	epatch "${psd}"/WindowMaker-0.92.0-alt-newpo.patch

	[[ ${CHOST} == *-interix* ]] && epatch "${FILESDIR}"/${PV}/${P}-interix3.patch
	epatch "${FILESDIR}"/${PV}/${P}-darwin-setlocale.patch
	epatch "${FILESDIR}"/${PV}/${P}-nls.patch
	#use nls && sed -i -e 's/#NLSENABLE //' configure.ac
	#touch ABOUT-NLS config.rpath

	# Add UK localisation
	cp "${psd}"/WindowMaker-uk.po po/uk.po
	cp "${psd}"/WPrefs-uk.po WPrefs.app/po/uk.po


	# Add newbuttons resources
	cp "${psd}"/WindowMaker-newbuttons.nextstyle.tiff \
		WPrefs.app/tiff/nextstyle.tiff
	cp "${psd}"/WindowMaker-newbuttons.oldstyle.tiff \
		WPrefs.app/tiff/oldstyle.tiff
	cp "${psd}"/WindowMaker-newbuttons.nextstyle.xpm \
		WPrefs.app/xpm/nextstyle.xpm

	# Fix some paths
	if use gnustep; then
		egnustep_env
	fi
	for file in "${S}"/WindowMaker/*menu*; do
		if [ -r "$file" ]; then
			if use gnustep ; then
				sed -i "s:/usr/local/GNUstep/Applications:${GNUSTEP_SYSTEM_APPS}:g" "$file"
			else
				sed -i "s:/usr/local/GNUstep/Applications/WPrefs.app:${EPREFIX}/usr/bin/:g;" "$file"
			fi

			sed -i 's:/usr/local/share/WindowMaker:${EPREFIX}/usr/share/WindowMaker:g;' "$file"
			sed -i 's:/opt/share/WindowMaker:${EPREFIX}/usr/share/WindowMaker:g;' "$file"
		fi;
	done;

	eautoreconf || die "eautoreconf failed"
}

src_compile() {
	local myconf

	# image format types
	# xpm is provided by X itself
	myconf="--enable-xpm $(use_enable png) $(use_enable jpeg) $(use_enable gif) $(use_enable tiff)"

	# non required X capabilities
	myconf="${myconf} $(use_enable modelock) $(use_enable xinerama)"

	if use gnustep ; then
		egnustep_env
		# Gentoo installs everything in System, make sure configure honors that
		export GNUSTEP_LOCAL_ROOT=${GNUSTEP_SYSTEM_ROOT}
		myconf="${myconf} --with-gnustepdir=${GNUSTEP_SYSTEM_ROOT}"
	fi

	if use nls; then
		[ -z "$LINGUAS" ] && export LINGUAS="`ls po/*.po | sed 's:po/\(.*\)\.po$:\1:'`"
	else
		myconf="${myconf} --disable-locale"
	fi

	# enable new features, need to be done via defines
	append-flags -DBOUNCE_APP -DNEWAPPICON
	use vdesktop && append-flags -DVIRTUAL_DESKTOP

	# default settings with $myconf appended
	econf \
		--sysconfdir="${EPREFIX}"/etc/X11 \
		--with-x \
		--enable-usermenu \
		--with-pixmapdir="${EPREFIX}"/usr/share/pixmaps \
		--with-nlsdir="${EPREFIX}"/usr/share/locale \
		${myconf} || die

	emake || die "windowmaker: make has failed"

	# WindowMaker Extra Package (themes and icons)
	cd ../WindowMaker-extra-0.1
	econf || die "windowmaker-extra: configure has failed"
	emake || die "windowmaker-extra: make has failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "windowmaker: install has failed."

	dodoc AUTHORS BUGFORM BUGS ChangeLog COPYING* INSTALL* FAQ* \
		  MIRRORS README* NEWS TODO

	# WindowMaker Extra
	cd ../WindowMaker-extra-0.1
	emake DESTDIR="${D}" install || die "windowmaker-extra: install failed"

	newdoc README README.extra

	# create wmaker session shell script
	echo "#!/usr/bin/env bash" > wmaker
	echo "${EPREFIX}/usr/bin/wmaker" >> wmaker
	exeinto /etc/X11/Sessions/
	doexe wmaker

	insinto /etc/X11/dm/Sessions
	doins "${FILESDIR}"/wmaker.desktop
	make_desktop_entry /usr/bin/wmaker
}
