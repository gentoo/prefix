# Copyright 2008-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

DESCRIPTION="An Interix to native Win32 Cross-Compiler Tool (requires Visual Studio)."
HOMEPAGE="http://www.sourceforge.net/projects/parity/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~x86-interix ~x86-winnt"
IUSE=""

pkg_setup() {
	if [ -z "${MSSDK}" ]; then
		einfo "NOTE: When using Visual Studio 2008, the Platform SDK is no longer"
		einfo "installed alongside with the other components, but has it's own"
		einfo "root directory, most likely something like this:"
		einfo ""
		einfo "  C:\\Program Files\\Microsoft SDKs\\Windows\\v6.0A"
		einfo ""
		einfo "To make parity find it's paths correctly, please set MSSDK to the"
		einfo "value correspoding to the above example for your system."
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# upstream in svn for 1.1.1
	epatch "${FILESDIR}"/${P}-entry-points.patch
}

src_compile() {
	# parity's configure script has tons of magic to detect propper
	# visual studio installations, which would be much too much here.

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# create i586-pc-winnt*-g[++|cc|..] links..
	local exeext=

	[[ -f ${ED}/usr/bin/parity.gnu.gcc.exe ]] && exeext=.exe

	dobin "${FILESDIR}"/parity-prefix-wrapper.sh
	sed -i -e "s,@EXEEXT@,$exeext,g" "${ED}"/usr/bin/parity-prefix-wrapper.sh

	for x in c++ g++ gcc ld; do
		dosym /usr/bin/parity-prefix-wrapper.sh /usr/bin/${CHOST}-${x}
	done
}

