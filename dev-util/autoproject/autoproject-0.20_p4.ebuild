# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/autoproject/autoproject-0.20_p4.ebuild,v 1.1 2007/02/16 05:34:55 vapier Exp $

inherit eutils

MY_PV=${PV%_p*}
DEB_VER=${PV#*_p}
DESCRIPTION="Used to start a programming project using autoconf, automake, and optionally a command line parser generator"
HOMEPAGE="http://packages.debian.org/unstable/devel/autoproject"
SRC_URI="mirror://debian/pool/main/a/autoproject/${PN}_${MY_PV}.orig.tar.gz
	mirror://debian/pool/main/a/autoproject/${PN}_${MY_PV}-${DEB_VER}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="test"

RDEPEND="sys-devel/automake
	sys-devel/autoconf"
DEPEND="${RDEPEND}
	test? ( sys-apps/texinfo )"

S=${WORKDIR}/${PN}-${MY_PV}

src_unpack() {
	unpack ${A}
	epatch ${PN}_${MY_PV}-${DEB_VER}.diff
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS NEWS README TODO ChangeLog
}
