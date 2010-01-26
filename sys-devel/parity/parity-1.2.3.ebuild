# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

DESCRIPTION="An Interix to native Win32 Cross-Compiler Tool (requires Visual Studio)."
HOMEPAGE="http://www.sourceforge.net/projects/parity/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~x86-interix ~x86-winnt"
IUSE=""

DEPEND="dev-util/confix"

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

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# create i586-pc-winnt*-g[++|cc|..] links..

	local exeext=
	[[ -f ${ED}/usr/bin/parity.gnu.gcc.exe ]] && exeext=.exe

	# create cross compiler syms
	dosym /usr/bin/parity.gnu.gcc${exeext} /usr/bin/i586-pc-winnt$(uname -r)-gcc
	dosym /usr/bin/parity.gnu.gcc${exeext} /usr/bin/i586-pc-winnt$(uname -r)-c++
	dosym /usr/bin/parity.gnu.gcc${exeext} /usr/bin/i586-pc-winnt$(uname -r)-g++
	dosym /usr/bin/parity.gnu.ld${exeext} /usr/bin/i586-pc-winnt$(uname -r)-ld
}

