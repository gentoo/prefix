# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/cracklib/cracklib-2.8.12.ebuild,v 1.8 2008/02/24 11:38:13 vapier Exp $

inherit toolchain-funcs multilib autotools

MY_P=${P/_}
DESCRIPTION="Password Checking Library"
HOMEPAGE="http://sourceforge.net/projects/cracklib"
SRC_URI="mirror://sourceforge/cracklib/${MY_P}.tar.gz"

LICENSE="CRACKLIB"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="nls python"

DEPEND="python? ( dev-lang/python )"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	# workaround #195017
	if has unmerge-orphans ${FEATURES} && has_version "<${CATEGORY}/${PN}-2.8.10" ; then
		eerror "Upgrade path is broken with FEATURES=unmerge-orphans"
		eerror "Please run: FEATURES=-unmerge-orphans emerge cracklib"
		die "Please run: FEATURES=-unmerge-orphans emerge cracklib"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-interix.patch

	AT_M4DIR="m4" eautoreconf # need new libtool for interix
}

src_compile() {
	econf \
		--with-default-dict='$(libdir)/cracklib_dict' \
		$(use_enable nls) \
		$(use_with python) \
		|| die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	rm -r "${ED}"/usr/share/cracklib

	# move shared libs to /
	dodir /$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/*$(get_libname)* "${ED}"/$(get_libdir)/ || die "could not move shared"
	gen_usr_ldscript libcrack$(get_libname)

	insinto /usr/share/dict
	doins dicts/cracklib-small || die "word dict"

	dodoc AUTHORS ChangeLog NEWS README*
}

pkg_postinst() {
	if [[ ${ROOT} == "/" ]] ; then
		ebegin "Regenerating cracklib dictionary"
		create-cracklib-dict "${EPREFIX}"/usr/share/dict/* > /dev/null
		eend $?
	fi
}
