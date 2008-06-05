# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler-bindings/poppler-bindings-0.6.2.ebuild,v 1.2 2007/12/05 18:51:18 cardoe Exp $

EAPI="prefix"

inherit autotools eutils multilib

MY_P=${P/-bindings/}
DESCRIPTION="rendering bindings for GUI toolkits for poppler"
HOMEPAGE="http://poppler.freedesktop.org/"

# Creating the testsuite tarball (must be done for every release)
#
# cvs -d :pserver:anoncvs@cvs.freedesktop.org:/cvs/poppler login
# cvs -d :pserver:anoncvs@cvs.freedesktop.org:/cvs/poppler co test
# tar czf poppler-test-${PV}.tar.gz
# upload to d.g.o/space/distfiles-local

SRC_URI="http://poppler.freedesktop.org/${MY_P}.tar.gz
		test? ( mirror://gentoo/poppler-test-0.6.1.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="gtk qt3 cairo qt4 test"

RDEPEND="~app-text/poppler-${PV}
	cairo? ( >=x11-libs/cairo-1.4 )
	gtk? (
		>=x11-libs/gtk+-2.6
		>=gnome-base/libglade-2
	)
	qt3? ( =x11-libs/qt-3* )
	qt4? ( =x11-libs/qt-4* )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=sys-devel/automake-1.9.6"

S=${WORKDIR}/${MY_P}

src_unpack(){
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/poppler-0.6-bindings.patch

	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	# Configure needs help finding qt libs on multilib systems
	export QTLIB="${QTDIR}/$(get_libdir)"
	echo $QTLIB

	econf --enable-opi \
		$(use_enable cairo cairo-output) \
		$(use_enable gtk poppler-glib) \
		$(use_enable qt3 poppler-qt) \
		$(use_enable qt4 poppler-qt4) \
		|| die "configuration failed"
	cd poppler
	if use cairo; then
		emake libpoppler-cairo.la || die "cairo failed"
	fi
	if use qt4; then
		emake libpoppler-arthur.la || die "arthur failed"
	fi
	cd ..
	emake || die "compilation failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

pkg_postinst() {
	ewarn "You need to rebuild everything depending on poppler, use revdep-rebuild"
}
