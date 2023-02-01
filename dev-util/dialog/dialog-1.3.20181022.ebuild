# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils multilib versionator

DIA_P="${PN}-$(replace_version_separator 2 '-')"
DESCRIPTION="tool to display dialog boxes from a shell"
HOMEPAGE="https://invisible-island.net/dialog/"
SRC_URI="https://dev.gentoo.org/~jer/${DIA_P}.tgz"

LICENSE="GPL-2"
SLOT="0/15"
KEYWORDS="~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="examples minimal nls static-libs unicode"

RDEPEND="
	>=sys-libs/ncurses-5.2-r5:=[unicode?]
"
DEPEND="
	${RDEPEND}
	nls? ( sys-devel/gettext )
	!minimal? ( sys-devel/libtool )
	!<=sys-freebsd/freebsd-contrib-8.9999
"
S=${WORKDIR}/${DIA_P}

src_prepare() {
	default
	sed -i -e '/LIB_CREATE=/s:${CC}:& ${LDFLAGS}:g' configure || die
	sed -i '/$(LIBTOOL_COMPILE)/s:$: $(LIBTOOL_OPTS):' makefile.in || die
	# configure searches all over the world for some things...
	sed -i configure \
		-e 's:^test -d "\(/usr\|$prefix\|/usr/local\|/opt\|$HOME\):test -d "XnoX:' || die
}

src_configure() {
	# doing this libtool stuff through configure
	# (--with-libtool=/path/to/libtool) strangely breaks the build
	local glibtool="libtool"
	[[ ${CHOST} == *-darwin* ]] && glibtool="glibtool"
	export ac_cv_path_LIBTOOL="$(type -P ${glibtool})"

	econf \
		--disable-rpath-hack \
		$(use_enable nls) \
		$(use_with !minimal libtool) \
		--with-libtool-opts=$(usex static-libs '' '-shared') \
		--with-ncurses$(usex unicode w '')
}

src_install() {
	use minimal && default || emake DESTDIR="${D}" install-full

	use examples && dodoc -r samples

	dodoc CHANGES README

	prune_libtool_files
}
