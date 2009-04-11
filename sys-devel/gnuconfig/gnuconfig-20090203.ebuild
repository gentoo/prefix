# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gnuconfig/gnuconfig-20090203.ebuild,v 1.1 2009/03/09 21:32:35 vapier Exp $

inherit eutils
if [[ ${PV} == "99999999" ]] ; then
	EGIT_REPO_URI="git://git.savannah.gnu.org/config.git"
	inherit git
else
	SRC_URI="mirror://gentoo/${P}.tar.bz2"
	KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi

DESCRIPTION="Updated config.sub and config.guess file from GNU"
HOMEPAGE="http://savannah.gnu.org/projects/config"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

S=${WORKDIR}

maint_pkg_create() {
	cd "${S}"

	local ver=$(head -n 1 ChangeLog | awk '{print $1}' | sed -e 's:-::g')
	[[ ${#ver} != 8 ]] && die "invalid version '${ver}'"

	cp "${FILESDIR}"/${PV}/*.patch . || die

	local tar="${T}/gnuconfig-${ver}.tar.bz2"
	tar -jcf ${tar} . || die "creating tar failed"
	einfo "Packaged tar now available:"
	einfo "$(du -b ${tar})"
}

src_unpack() {
	if [[ ${PV} == "99999999" ]] ; then
		git_src_unpack
		maint_pkg_create
	else
		unpack ${A}
	fi
	epatch "${WORKDIR}"/*.patch
	sed -i '/i386-pc-solaris2.6/d' testsuite/config-guess.data
	use elibc_uclibc && sed -i 's:linux-gnu:linux-uclibc:' testsuite/config-guess.data #180637
}

src_compile() { :;}

src_install() {
	insinto /usr/share/${PN}
	doins config.{sub,guess} || die
	fperms +x /usr/share/${PN}/config.{sub,guess}
	dodoc ChangeLog
}
