# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/xsane/xsane-0.997.ebuild,v 1.2 2010/06/21 15:21:40 ssuominen Exp $

inherit eutils

DESCRIPTION="graphical scanning frontend"
HOMEPAGE="http://www.xsane.org/"
SRC_URI="http://www.xsane.org/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="nls jpeg png tiff gimp lcms"

RDEPEND="media-gfx/sane-backends
	>=x11-libs/gtk+-2.0
	jpeg? ( >=media-libs/jpeg-8a )
	png? ( media-libs/libpng )
	tiff? ( media-libs/tiff )
	gimp? ( media-gfx/gimp )
	lcms? ( =media-libs/lcms-1* )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	export OLDXSANE
	if has_version '<=media-gfx/xsane-0.93'; then
		OLDXSANE="yes"
	else
		OLDXSANE="no"
	fi
}

src_compile() {
	local extraCPPflags
	if use lcms; then
		extraCPPflags="-I ${EPREFIX}/usr/include/lcms"
	fi
	CPPFLAGS="${CPPFLAGS} ${extraCPPflags}" econf --enable-gtk2 \
		$(use_enable nls) \
		$(use_enable jpeg) \
		$(use_enable png) \
		$(use_enable tiff) \
		$(use_enable gimp) \
		$(use_enable lcms) \
		|| die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc xsane.*
	# link xsane so it is seen as a plugin in gimp
	if use gimp; then
		local plugindir
		if [ -x ${EPREFIX}/usr/bin/gimptool ]; then
			plugindir="$(gimptool --gimpplugindir)/plug-ins"
		elif [ -x ${EPREFIX}/usr/bin/gimptool-2.0 ]; then
			plugindir="$(gimptool-2.0 --gimpplugindir)/plug-ins"
		else
			die "Can't find GIMP plugin directory."
		fi
		dodir "${plugindir#${EPREFIX}}"
		dosym /usr/bin/xsane "${plugindir#${EPREFIX}}"
	fi
	newicon src/xsane-48x48.png ${PN}.png
}

pkg_postinst() {
	if [ x${OLDXSANE} = 'xyes' ]; then
		ewarn "If you are upgrading from <=xsane-0.93, please make sure to"
		ewarn "remove ~/.sane/xsane/xsane.rc _before_ you start xsane for"
		ewarn "the first time."
	fi
}
