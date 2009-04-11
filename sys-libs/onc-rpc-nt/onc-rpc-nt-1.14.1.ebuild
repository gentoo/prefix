# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="ONC RPC for Windows NT"
HOMEPAGE="http://dev.gentoo.org/~mduft/rpc"
SRC_URI="${HOMEPAGE}/onc-rpc-nt-1.14.1.tar.gz"

LICENSE="sun-rpc"
SLOT="0"
KEYWORDS="-* ~x86-winnt"

src_install() {
	emake DESTDIR="${D}" install

	local exeext=
	[[ -f "${ED}"/usr/bin/rpcgen.exe ]] && exeext=".exe"

	for x in rpcgen rpcinfo portmap; do
		dosym /usr/bin/$x$exeext /usr/bin/${CHOST}-$x
	done
}
