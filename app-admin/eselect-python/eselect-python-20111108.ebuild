# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-python/eselect-python-20111108.ebuild,v 1.2 2012/04/26 14:53:20 aballier Exp $

# Keep the EAPI low here because everything else depends on it.
# We want to make upgrading simpler.

inherit flag-o-matic prefix

ESVN_PROJECT="eselect-python"
ESVN_REPO_URI="https://overlays.gentoo.org/svn/proj/python/projects/eselect-python/trunk"

if [[ ${PV} == "99999999" ]] ; then
	inherit autotools subversion
else
	SRC_URI="mirror://gentoo/${P}.tar.bz2"
	KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi

DESCRIPTION="Eselect module for management of multiple Python versions"
HOMEPAGE="http://www.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND=">=app-admin/eselect-1.2.3"
DEPEND="${RDEPEND}
	sparc-solaris? ( dev-libs/gnulib )"

# Avoid autotool deps for released versions for circ dep issues.
if [[ ${PV} == "99999999" ]] ; then
	DEPEND="sys-devel/autoconf"
else
	DEPEND=""
fi

pkg_setup() {
	if [[ ${CHOST} == *-solaris2.9 ]] ; then
		# solaris2.9 does not have scandir yet
		append-flags -I"${EPREFIX}/usr/$(get_libdir)/gnulib/include"
		append-ldflags -L"${EPREFIX}/usr/$(get_libdir)/gnulib/$(get_libdir)"
		append-libs -lgnu
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-20100321-prefix.patch
	[[ -x configure ]] || eautoreconf
}

src_compile() {
	use prefix && append-flags -DEPREFIX='"\"'"${EPREFIX}"'\""'
	econf || die
	emake || die
}

src_install() {
	keepdir /etc/env.d/python
	emake DESTDIR="${D}" install || die
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-20090804" || ! has_version "${CATEGORY}/${PN}"; then
		run_eselect_python_update="1"
	fi
}

pkg_postinst() {
	if [[ "${run_eselect_python_update}" == "1" ]]; then
		ebegin "Running \`eselect python update\`"
		eselect python update --ignore 3.0 --ignore 3.1 --ignore 3.2 > /dev/null
		eend "$?"
	fi
}
