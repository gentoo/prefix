# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/portage-utils/portage-utils-0.1.21.ebuild,v 1.1 2006/08/21 16:44:28 solar Exp $

EAPI="prefix"

inherit toolchain-funcs

DESCRIPTION="small and fast portage helper tools written in C"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="python"

DEPEND=""

src_compile() {
	use python && export PYTHON=1
	unset PYTHON
	emake || die
}

src_install() {
	dobin q || die "dobin failed"
	doman man/*.[0-9]
	for applet in $(<applet-list) ; do
		dosym q /usr/bin/${applet}
	done
}

pkg_postinst() {
	[ -e ${ROOT}/etc/portage/bin/post_sync ] && return 0
	mkdir -p ${ROOT}/etc/portage/bin/

cat <<__EOF__ > ${ROOT}/etc/portage/bin/post_sync
#!${EPREFIX}/bin/sh
# Copyright 2006-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

if [ -d ${EPREFIX}/etc/portage/postsync.d/ ]; then
	for f in ${EPREFIX}/etc/portage/postsync.d/* ; do
		if [ -x \${f} ] ; then
			\${f}
		fi
	done
else
	:
fi
__EOF__
	chmod 755 ${ROOT}/etc/portage/bin/post_sync
	if [ ! -e ${ROOT}/etc/portage/postsync.d/q-reinitialize ]; then
		mkdir -p ${ROOT}/etc/portage/postsync.d/
		echo '[ -x '"${EPREFIX}"'/usr/bin/q ] && '"${EPREFIX}"'/usr/bin/q -r' > ${ROOT}/etc/portage/postsync.d/q-reinitialize
		einfo "${ROOT}/etc/portage/postsync.d/q-reinitialize has been installed for convenience"
		einfo "If you wish for it to be automatically run at the end of every --sync simply chmod +x ${ROOT}/etc/portage/postsync.d/q-reinitialize"
		einfo "Normally this should only take a few seconds to run but file systems such as ext3 can take a lot longer."
		einfo "If ever you find this to be an inconvenience simply chmod -x ${ROOT}/etc/portage/postsync.d/q-reinitialize"
	fi
	:
}
