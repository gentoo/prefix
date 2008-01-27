# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/sitecopy/sitecopy-0.16.3-r1.ebuild,v 1.2 2008/01/26 16:59:39 armin76 Exp $

EAPI="prefix"

inherit eutils autotools

IUSE="expat nls rsh ssl webdav xml zlib"

DEB_PL="14"
DESCRIPTION="sitecopy is for easily maintaining remote web sites"
SRC_URI="http://www.lyra.org/${PN}/${P}.tar.gz
	mirror://debian/pool/main/s/${PN}/${P/-/_}-${DEB_PL}.diff.gz"
HOMEPAGE="http://www.lyra.org/sitecopy/"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
LICENSE="GPL-2"
SLOT="0"
DEPEND="rsh? ( net-misc/netkit-rsh )
	>=net-misc/neon-0.24.6"

pkg_setup() {
	if use zlib ; then
		built_with_use net-misc/neon zlib || die "neon needs zlib support"
	fi

	if use ssl ; then
		built_with_use net-misc/neon ssl || die "neon needs ssl support"
		myconf="${myconf} --with-ssl=openssl"
	fi

	if use expat ; then
		built_with_use net-misc/neon expat || die "neon needs expat support"
	fi

	if use xml ; then
		built_with_use net-misc/neon expat && die "neon needs expat support disabled for
		libxml2 support to be enabled"
	fi
}

src_unpack() {
	unpack ${A}

	# Debian patches
	epatch ${P/-/_}-${DEB_PL}.diff
	epatch "${S}"/debian/patches/*.dpatch

	cd "${S}"

	sed -i -e \
		"s:docdir \= .*:docdir \= \$\(prefix\)\/share/doc\/${PF}:" \
		Makefile.in || die "Documentation directory patching failed"

	eautoconf
	eautomake
}

src_compile() {
	econf ${myconf} \
			$(use_enable webdav) \
			$(use_enable nls) \
			$(use_enable rsh) \
			$(use_with expat) \
			$(use_with xml libxml2 ) \
			--with-neon \
			|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
