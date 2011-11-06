# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/dash/dash-0.5.7.1.ebuild,v 1.1 2011/09/15 03:54:56 vapier Exp $

EAPI="3"

inherit autotools eutils flag-o-matic toolchain-funcs

DEB_PV=${PV%.*}
DEB_PATCH=${PV##*.}
DEB_PF="${PN}_${DEB_PV}-${DEB_PATCH}"
MY_P="${PN}-${DEB_PV}"

DESCRIPTION="DASH is a direct descendant of the NetBSD version of ash (the Almquist SHell) and is POSIX compliant"
HOMEPAGE="http://gondor.apana.org.au/~herbert/dash/"
SRC_URI="http://gondor.apana.org.au/~herbert/dash/files/${PN}-${DEB_PV}.tar.gz
	mirror://debian/pool/main/d/dash/${DEB_PF}.diff.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="libedit static"

RDEPEND="!static? ( libedit? ( dev-libs/libedit ) )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	libedit? ( static? ( dev-libs/libedit[static-libs] ) )"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${WORKDIR}"/${DEB_PF}.diff
	epatch */debian/diff/*
	epatch "${FILESDIR}"/${PN}-0.5.5.1-octal.patch #337329

	# Fix the invalid sort
	sed -i -e 's/LC_COLLATE=C/LC_ALL=C/g' src/mkbuiltins

	# Use pkg-config for libedit linkage
	sed -i "/LIBS/s:-ledit:\`$(tc-getPKG_CONFIG) --libs libedit $(use static && echo --static)\`:" configure.ac

	# May as well, as the debian patches force this anyway
	eautoreconf
}

src_configure() {
	use static && append-ldflags -static
	econf \
		--bindir="${EPREFIX}"/bin \
		$(use_with libedit)
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog */debian/changelog
}
