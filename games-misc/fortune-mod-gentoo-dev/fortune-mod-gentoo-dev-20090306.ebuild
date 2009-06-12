# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-misc/fortune-mod-gentoo-dev/fortune-mod-gentoo-dev-20090306.ebuild,v 1.2 2009/05/29 17:00:01 beandog Exp $

DESCRIPTION="Fortune database of #gentoo-dev quotes"
HOMEPAGE="http://www.gentoo.org/"
MY_PN="fortune-gentoo-dev"
MY_P="${MY_PN}-${PV}"
SRC_URI="mirror://gentoo/${MY_P}.tar.bz2
		 http://dev.gentoo.org/~robbat2/distfiles/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="offensive"

RDEPEND="games-misc/fortune-mod"
# Perl is used to build stuff only
# and strfile belongs to fortune-mod
DEPEND="dev-lang/perl
		${RDEPEND}"

S="${WORKDIR}/${MY_P}"

src_compile() {
	emake \
		STRFILE="${EPREFIX}"/usr/bin/strfile \
		PERL="${EPREFIX}"/usr/bin/perl \
		RM="${EPREFIX}"/bin/rm \
		INSTALL="${EPREFIX}/usr/bin/install -c -m0644" \
		INSTALL_DIR="${EPREFIX}/usr/bin/install -c -m0755 -d" \
		FORTUNE_DIR="${EPREFIX}"/usr/share/fortune \
		|| die "emake failed"
}

src_install() {
	emake \
		STRFILE="${EPREFIX}"/usr/bin/strfile \
		PERL="${EPREFIX}"/usr/bin/perl \
		RM="${EPREFIX}"/bin/rm \
		INSTALL="${EPREFIX}/usr/bin/install -c -m0644" \
		INSTALL_DIR="${EPREFIX}/usr/bin/install -c -m0755 -d" \
		FORTUNE_DIR="${EPREFIX}"/usr/share/fortune \
		install DESTDIR="${D}" || die "emake install failed"
	use offensive || rm -f "${ED}"/usr/share/fortune/off/*
}
