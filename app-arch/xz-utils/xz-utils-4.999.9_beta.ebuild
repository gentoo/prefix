# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/xz-utils/xz-utils-4.999.9_beta.ebuild,v 1.1 2009/08/28 07:40:25 vapier Exp $

# Remember: we cannot leverage autotools in this ebuild in order
#           to avoid circular deps with autotools

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://ctrl.tukaani.org/xz.git"
	inherit git autotools
	SRC_URI=""
	EXTRA_DEPEND="sys-devel/gettext dev-util/cvs" #272880
else
	MY_P="${PN/-utils}-${PV/_}"
	SRC_URI="http://tukaani.org/xz/${MY_P}.tar.gz"
	KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-freebsd"
	S=${WORKDIR}/${MY_P}
	EXTRA_DEPEND=
fi

inherit eutils

DESCRIPTION="utils for managing LZMA compressed files"
HOMEPAGE="http://tukaani.org/xz/"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE=""

RDEPEND="!app-arch/lzma
	!app-arch/lzma-utils
	!<app-arch/p7zip-4.57"
DEPEND="${RDEPEND}
	${EXTRA_DEPEND}"

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git_src_unpack
		cd "${S}"
		./autogen.sh || die
	else
		unpack ${A}
		cd "${S}"
		sed -i 's:-static::' $(find -name Makefile.in)
	fi
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS
}
