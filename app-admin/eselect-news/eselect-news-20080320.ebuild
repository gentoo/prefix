# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-news/eselect-news-20080320.ebuild,v 1.11 2009/03/17 10:08:28 armin76 Exp $

DESCRIPTION="GLEP 42 news reader"
HOMEPAGE="http://paludis.pioto.org/"
SRC_URI="http://dev.gentooexperimental.org/~peper/distfiles/news.eselect-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.11"

src_unpack() {
	cp "${DISTDIR}/news.eselect-${PV}" "${T}/news.eselect-${PV}"
	sed -i -e "s|/var|${EPREFIX}/var|g" "${T}/news.eselect-${PV}" || die
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${T}/news.eselect-${PV}" news.eselect || die
	keepdir /var/lib/gentoo/news
}

pkg_postinst() {
	local paludis_data="${EROOT}var/lib/paludis/news" gentoo_data="${EROOT}var/lib/gentoo/news"

	if [[ -d "${paludis_data}" && ! -L "${paludis_data}" ]] ; then
		einfo "Merging news data at '${paludis_data}' with '${gentoo_data}'"

		local f fname
		for f in "${paludis_data}"/*.{read,unread,skip} ; do
			fname=$(basename "${f}")
			if [[ -f "${gentoo_data}/${fname}" ]] ; then
				cat "${gentoo_data}/${fname}" >> "${f}"
			fi
			sort -u "${f}" > "${gentoo_data}/${fname}"
		done
		rm -r "${paludis_data}"
		ln -s "${gentoo_data}" "${paludis_data}"
	fi
}
