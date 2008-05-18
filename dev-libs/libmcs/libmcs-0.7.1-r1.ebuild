# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libmcs/libmcs-0.7.1-r1.ebuild,v 1.1 2008/05/17 18:38:25 chainsaw Exp $

EAPI="prefix"

DESCRIPTION="Abstracts the storage of configuration settings away from applications."
HOMEPAGE="http://sacredspiral.co.uk/~nenolod/mcs/"
SRC_URI="http://distfiles.atheme.org/${P}.tgz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="gnome"

DEPEND=">=dev-util/pkgconfig-0.9.0
	${RDEPEND}"
RDEPEND=">=dev-libs/libmowgli-0.6.1
	gnome? ( >=gnome-base/gconf-2.6.0 )"

src_compile() {
	econf \
		$(use_enable gnome gconf) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS README TODO
}
