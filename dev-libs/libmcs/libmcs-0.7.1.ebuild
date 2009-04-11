# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libmcs/libmcs-0.7.1.ebuild,v 1.1 2008/04/20 23:13:54 chainsaw Exp $

inherit flag-o-matic kde-functions multilib

DESCRIPTION="Abstracts the storage of configuration settings away from applications."
HOMEPAGE="http://sacredspiral.co.uk/~nenolod/mcs/"
SRC_URI="http://distfiles.atheme.org/${P}.tgz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="gnome kde"

DEPEND=">=dev-util/pkgconfig-0.9.0
	${RDEPEND}"
RDEPEND=">=dev-libs/libmowgli-0.6.1
	gnome? ( >=gnome-base/gconf-2.6.0 )
	kde? ( kde-base/kdelibs )"

src_compile() {
	if use kde; then
	    set-kdedir
	    append-ldflags "-L${KDEDIR}/$(get_libdir)"
	    append-flags "-I${KDEDIR}/include -I${QTDIR}/include"
	fi
	econf \
		$(use_enable gnome gconf) \
		$(use_enable kde kconfig) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS README TODO
}
