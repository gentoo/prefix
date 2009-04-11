# Copyright 2008-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion

DESCRIPTION="An Interix to native Win32 Cross-Compiler Tool (requires Visual Studio)."
HOMEPAGE="http://www.sourceforge.net/projects/parity/"
ESVN_REPO_URI="https://parity.svn.sf.net/svnroot/parity/trunk"
ESVN_BOOTSTRAP="confix --bootstrap"
ESVN_PROJECT="${PN}"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS=""
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

	dobin "${FILESDIR}"/parity-prefix-wrapper.sh
	sed -i -e "s,@EXEEXT@,$exeext,g" "${ED}"/usr/bin/parity-prefix-wrapper.sh

	for x in c++ g++ gcc ld; do
		dosym /usr/bin/parity-prefix-wrapper.sh /usr/bin/i586-pc-winnt$(uname -r)-${x}
	done

	# we don't need the header files installed by parity... private
	# header files are supported with a patch from 2.1.0-r1 onwards,
	# so they won't be there anymore, but -f does the job in any case.
	rm -f "${ED}"/usr/include/*.h
}

