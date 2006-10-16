# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/iiimf.eclass,v 1.14 2006/10/14 10:19:09 flameeyes Exp $
#
# Author: Mamoru KOMACHI <usata@gentoo.org>
#
# The IIIMF eclass is used for compilation and installation of IIIMF
# libraries, servers, clients and modules within the Portage system.
#

WANT_AUTOMAKE="1.4"
WANT_AUTOCONF="2.1"

inherit autotools

EXPORT_FUNCTIONS src_compile src_install

IMSDK_PV="r${PV//./_}"
MY_PV="${IMSDK_PV/_pre/-svn}"
MY_PV="${MY_PV/_p/-svn}"
IMSDK_P="im-sdk-src-${MY_PV}"
IMSDK="${IMSDK_P/-src/}"

DESCRIPTION="Based on the $ECLASS eclass"
HOMEPAGE="http://www.openi18n.org/subgroups/im/IIIMF/"
SRC_URI="mirror://gentoo/${IMSDK_P}.tgz
	http://dev.gentoo.org/~usata/distfiles/${IMSDK_P}.tgz"

LICENSE="MIT X11"
SLOT="0"
KEYWORDS="~x86"
IUSE="debug"

S="${WORKDIR}/${IMSDK}/${PN}"

RDEPEND=""
DEPEND="dev-util/pkgconfig"

iiimf_src_compile() {

	if [ "${PV:0:2}" -eq 12 ] ; then
		eautoreconf
	fi

	econf --enable-optimize \
		--localstatedir=/var \
		$(use_enable debug) || die
	# emake doesn't work on some libraries
	emake -j1 || die
}

iiimf_src_install() {

	einstall || die

	dodoc ChangeLog
}

