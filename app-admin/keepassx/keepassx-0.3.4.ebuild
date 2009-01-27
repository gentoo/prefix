# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/keepassx/keepassx-0.3.4.ebuild,v 1.3 2009/01/27 10:51:10 armin76 Exp $

EAPI="prefix 2"

inherit eutils qt4

DESCRIPTION="Qt password manager compatible with its Win32 and Pocket PC versions."
HOMEPAGE="http://keepassx.sourceforge.net/"
SRC_URI="mirror://sourceforge/keepassx/KeePassX-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug"
DEPEND="|| ( ( x11-libs/qt-core:4[qt3support]
			x11-libs/qt-gui:4[qt3support]
			x11-libs/qt-xmlpatterns:4 )
		( =x11-libs/qt-4.3*:4[png,qt3support,zlib] ) )"
RDEPEND="${DEPEND}"

src_configure() {
	# generate translations
	cd "${S}/src"
	lrelease src.pro || die "lrelease failed"
	mv "${S}"/src/translations/*.qm "${S}"/share/keepassx/i18n

	cd "${S}"
	use debug && myconf="DEBUG=1"
	eqmake4 ${PN}.pro PREFIX="${ED}/usr" ${myconf} || die "eqmake4 failed"
}

src_compile(){
	# workaround compile failure due to distcc, bug #214327
	PATH=${PATH/\/usr\/lib\/distcc\/bin:}
	emake || die "emake failed"
}

src_install(){
	# workaround pre-stripping the keepassx binary during install, bug #248711
	sed -i -e '/strip/d' "${S}"/src/Makefile || die "sed failed"

	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc changelog todo || die "dodoc failed"
}
