# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/hunspell/hunspell-1.2.3.ebuild,v 1.2 2008/06/17 17:21:33 mr_bones_ Exp $

EAPI="prefix"

inherit eutils multilib autotools

MY_P=${PN}-${PV/_beta/b}

DESCRIPTION="Hunspell spell checker - an improved replacement for myspell in OOo."
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
HOMEPAGE="http://hunspell.sourceforge.net/"

SLOT="0"
LICENSE="MPL-1.1 GPL-2 LGPL-2.1"
IUSE="ncurses nls readline"
KEYWORDS="~amd64-linux ~x86-linux"

DEPEND="readline? ( sys-libs/readline )
	ncurses? ( sys-libs/ncurses )
	sys-devel/gettext"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Upstream package creates some executables which names are too generic
	# to be placed in /usr/bin - this patch prefixes them with 'hunspell-'.
	# It modifies a Makefile.am file, hence eautoreconf.
	epatch "${FILESDIR}"/${PN}-1.2.2-renameexes.patch

	eautoreconf
}

pkg_setup() {
	# Workaround as it's impossible to build with readline but witout ncurses.
	# http://sourceforge.net/tracker/index.php?func=detail&aid=1995842&group_id=143754&atid=756395
	if use ncurses; then
		myconf=$(use_with ncurses ui)
		use readline && myconf="${myconf} $(use_with readline readline)"
	else
		if use readline; then
			ewarn "readline USE flag has no effect without ncruses."
		fi
	fi
}

src_compile() {
	# I wanted to put the include files in /usr/include/hunspell
	# but this means the openoffice build won't find them.
	econf ${myconf} \
		$(use_with nls) \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO license.hunspell || die "installing docs failed"
	# hunspell is derived from myspell
	dodoc AUTHORS.myspell README.myspell license.myspell || die "installing myspell docs failed"

	# Upstream install has a few problems - rather than try to figure out
	# what's broken in the build system, just fix things up manually.

	# These are in the wrong place.
	mv "${ED}"/usr/include/munch.h "${ED}"/usr/include/hunspell/munch.h
	mv "${ED}"/usr/include/unmunch.h "${ED}"/usr/include/hunspell/unmunch.h

	# Libraries include the version in their name, so make a sensible
	# default symlink. They should probably be libhunspell.so.1.1 etc.
	dodir /usr/$(get_libdir)
	cd "${ED}"/usr/$(get_libdir)
	ln -s libhunspell-1.2.so.0.0.0 libhunspell.so
}

pkg_postinst() {
	elog "To use this package you will also need a dictionary."
	elog "Hunspell uses myspell format dictionaries; find them"
	elog "in the app-dicts category as myspell-<LANG>."
}
