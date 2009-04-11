# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/perl-tk/perl-tk-804.027.ebuild,v 1.26 2008/12/23 18:54:48 robbat2 Exp $

inherit perl-module eutils multilib

MY_P=Tk-${PV}
S=${WORKDIR}/${MY_P}
DESCRIPTION="A Perl Module for Tk"
HOMEPAGE="http://search.cpan.org/~ni-s/"
SRC_URI="mirror://cpan/authors/id/N/NI/NI-S/${MY_P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="x11-libs/libX11
	dev-lang/perl"

myconf="-I${EPREFIX}/usr/include/ -l${EPREFIX}/usr/$(get_libdir)"

mydoc="ToDo VERSIONS"

# No test running here, requires an X server, and fails lots anyway.
SRC_TEST="skip"

export X11="${EPREFIX}"/usr

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/xorg.patch

	# this should help on all other platforms too, to find the
	# correct X11 version from EPREFIX.
	epatch "${FILESDIR}"/${P}-interix-x11.patch
}
