# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/libtool-2.2.6a.ebuild,v 1.3 2008/11/28 22:41:19 ulm Exp $

LIBTOOLIZE="true" #225559
inherit eutils autotools

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.lzma"

LICENSE="GPL-2"
SLOT="1.5"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="vanilla"

RDEPEND="sys-devel/gnuconfig
	>=sys-devel/autoconf-2.60
	>=sys-devel/automake-1.10.1"
DEPEND="${RDEPEND}
	app-arch/lzma-utils
	sys-apps/help2man"

S=${WORKDIR}/${P%a}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PV}/${P}-gnuinfo.patch #249168

	if ! use vanilla ; then
		[[ ${CHOST} == *-winnt* || ${CHOST} == *-interix* ]] &&
			epatch "${FILESDIR}"/${PV}/${P}-winnt.patch
		epatch "${FILESDIR}"/${PV}/${P}-mint.patch

		epunt_cxx
		cd libltdl/m4
		epatch "${FILESDIR}"/1.5.20/${PN}-1.5.20-use-linux-version-in-fbsd.patch #109105
		epatch "${FILESDIR}"/${PV}/${P}-darwin-module-bundle.patch
		cd ..
		eautoreconf
		cd ..
		eautoreconf
	fi
}

src_compile() {
	local myconf
	# usr/bin/libtool is provided by binutils-apple
	[[ ${CHOST} == *-darwin* ]] && myconf="--program-prefix=g"
	econf ${myconf} || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* NEWS README THANKS TODO doc/PLATFORMS

	local p=
	[[ ${CHOST} == *-darwin* ]] && p=g
	local x
	for x in ${p}libtool ${p}libtoolize ; do
		help2man ${x} > ${x}.1
		doman ${x}.1 || die
	done

	for x in $(find "${ED}" -name config.guess -o -name config.sub) ; do
		rm -f "${x}" ; ln -sf "${EPREFIX}"/usr/share/gnuconfig/${x##*/} "${x}"
	done
}
